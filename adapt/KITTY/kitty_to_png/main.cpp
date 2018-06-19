#include <iostream>
#include <math.h>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <sstream>
//#include <opencv2/opencv.hpp>
#include <Eigen/Core>
#include <boost/filesystem.hpp>
#include <getopt.h>

using namespace std;
namespace bf = boost::filesystem;
namespace ei = Eigen;

static struct option long_opt[] = {
    {"range",           required_argument,      0,   'r'    },
    {"downsampling",    required_argument,      0,   'd'    },
    {"lidar",           required_argument,      0,   'l'    },
    {"save",            required_argument,      0,   's'    },
    {"image",           required_argument,      0,   'i'    },
    {"help",            no_argument,            0,   'h'    },
    {0,                 0,                      0,   0      }
};

void parse_error(string message = "Try '--help' for more information.\n")
{
    fprintf(stderr,message.c_str());
    exit(1);
}

string findName(int c)
{
    for (size_t i = 0; i < sizeof(long_opt); i++)
       {
          if (long_opt[i].val == c)
              return long_opt[i].name;
       }
    return "?";
}

bool createDirs(bf::path p)
{
    cout<<endl<<p<<endl;
    if(bf::create_directories(p))
    {
        cout<<"Directory created"<<endl;
        return true;
    }
    else
    {
        cout<<"Error creating directory"<<endl;
        return false;
    }
}

bool verifyDir(bf::path p)
{
    cout<<endl<<p<<endl;
    if(bf::exists(p))
    {
        if(bf::is_directory(p))
        {
            cout<<"Correct directory"<<endl;
            return true;
        }
        else
        {
            cout<<"Is not a directory"<<endl;
            return false;
        }
    }
    else
    {
        char op;
        cout<<"Doesn't exist"<<endl;
        cout<<"Do you want to create it? [y/n]"<<endl;
        cin>>op;
        if(op == 'y')
        {
            if(createDirs(p)) exit(1);
            return true;
        }
        else return false;
    }
}

bool hasFiles(bf::path p, string ext)
{
    cout<<endl<<p<<endl;
    if(bf::is_empty(p))
    {
        cout<<"Empty directory"<<endl;
        return false;
    }
    else
    {
        uint count = 0;
        vector<bf::path> v;
        copy(bf::directory_iterator(p), bf::directory_iterator(), back_inserter(v));
        sort(v.begin(), v.end());
        vector<bf::path>::iterator it = v.begin();
        for(; it != v.end(); it++) count++;
        cout<<"Has "<<count<<" ."<<ext<< " files"<<endl;
        return true;
    }
}

int main(int argc, char **argv)
{
    if (argc == 1) parse_error();

    bf::path lidarPath, imagePath, savePath;
    float downsampling, range;

    /*****************************Parser*****************************/
    int c, longindex=0;
    const char *short_opt = "r:d:l:s:i:h";
    char f[4] = { 'r', 'd', 'l', 's'};
    std::vector<int> flags(&f[0], &f[0]+4);
    ostringstream msg;

    while ((c = getopt_long(argc, argv, short_opt, long_opt, &longindex)) != -1)
    {
        switch (c)
        {
        case 'r':
            range = atof(optarg);
            printf("range '%f' meters\n", range);
            if((int)distance(remove( flags.begin(), flags.end(), c), flags.end()) > 0) flags.pop_back();
            else parse_error("Repeated mandatory argument -"+findName(c)+" \n");
            break;
        case 'd':
            downsampling = atof(optarg);
            printf("downsampling '%f'\n", downsampling);
            if((int)distance(remove( flags.begin(), flags.end(), c), flags.end()) > 0) flags.pop_back();
            else parse_error("Repeated mandatory argument -"+findName(c)+" \n");
            break;
        case 'l':
            lidarPath = optarg;
            printf("lidar '%s'\n", lidarPath.c_str());
            if((int)distance(remove( flags.begin(), flags.end(), c), flags.end()) > 0) flags.pop_back();
            else parse_error("Repeated mandatory argument -"+findName(c)+" \n");
            break;
        case 's':
            savePath = optarg;
            printf("save '%s'\n", savePath.c_str());
            if((int)distance(remove( flags.begin(), flags.end(), c), flags.end()) > 0) flags.pop_back();
            else parse_error("Repeated mandatory argument -"+findName(c)+" \n");
            break;
        case 'i':
            imagePath = optarg;
            printf("image '%s'\n", imagePath.c_str());
            break;
        case 'h':
            printf("Usage: %s mandatory [optional]\n", argv[0]);
            printf("\nMandatory args:\n");
            printf(" -r, --range        aproximate maximum lidar range\n");
            printf(" -d, --downsampling image downsampling factor\n");
            printf(" -l, --lidar        lidar sequence directory\n");
            printf(" -s, --save         save png images directory\n");
            printf("\nOptional args:\n");
            printf(" -i, --image        image sequence directory (default: lidar dir.\n");
            printf(" -h, --help         print this help and exit\n\n");
            exit(0);
        default:
            parse_error();
        }
    }

    if(flags.size() != 0)
    {
        msg.str("");
        msg<<"Missing: ";
        for( int i = 0; i < flags.size(); i++ )
            msg <<"-"<< (char)flags[i];
        msg<<" (mandatory arguments)"<<endl;
        parse_error(msg.str());
    }

    if (optind < argc)
    {
        printf("non-option ARGV-elements: ");
        while (optind < argc)
            printf("%s \n", argv[optind++]);
        parse_error();
    }


    /*****************************Program*****************************/
    if(is_empty(imagePath)) imagePath = lidarPath;

    ushort depthScale = round(pow(2,16)/range); //calculate depth sampling per meter
    printf("Scale %u   calculated depth scale (values/meter)\n", depthScale);
    printf("Precision   %f   meters\n", 1.0/depthScale);

    if(!verifyDir(lidarPath) or !hasFiles(lidarPath,"bin")) parse_error();
    if(!verifyDir(imagePath) or !hasFiles(imagePath,"png")) parse_error();
    if(!verifyDir(savePath)) parse_error("Error creating save path\n");

    bf::path saveImage = savePath /= imagePath.filename();
    bf::path saveLidar = savePath /= lidarPath.filename();
    if(!createDirs(saveImage) or !createDirs(saveLidar)) exit(1);

    //for every .bin in lidarPath
    //compute x,y and recenter top-left
    //D,I
    //Build ordered pointcloud
         //Initialize pointcloud to zero
         //Downsample image
         //for each point:
            //round(x,y / downsamling factor)
            //Process D
               //if D > max range --> D = max range
               //D = D·sampling
            //if D is non zero:
                //save smaller D
         //Interpolate regular?
         //Save png color and png depth
            //Matrix2opencv

    exit(0);
}


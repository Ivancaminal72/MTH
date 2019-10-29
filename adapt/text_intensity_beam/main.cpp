/*
 *
 *  Created on: 20/8/2018
 *      Author: Ivan Caminal
 */

#include <iostream>
#include <math.h>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <sstream>
#include <opencv2/opencv.hpp>
//#include <eigen3/Eigen/Core>
//#include <eigen3/Eigen/Geometry>
#include <Eigen/Core>
#include <Eigen/Geometry>
#include <pcl/io/pcd_io.h>
#include <pcl/point_types.h>
#include <boost/filesystem.hpp>
#include <getopt.h>

using namespace std;
using namespace cv;
namespace bf = boost::filesystem;
namespace ei = Eigen;

typedef ei::Matrix<float, 3, 4> Matrix34f;
typedef ei::Matrix<float, 1, ei::Dynamic> Matrix1Xf;
typedef ei::Matrix<uint32_t, 1, ei::Dynamic> Matrix1Xu;


static struct option long_opt[] = {
    {"range",           required_argument,      0,   'r'    },
    {"width",           required_argument,      0,   'w'    },
    {"heigh",           required_argument,      0,   'h'    },
    {"input",           required_argument,      0,   'i'    },
    {"sequence",        required_argument,      0,   's'    },
    {"output",          required_argument,      0,   'o'    },
    {"data",            required_argument,      0,   255+1  },
    {"frequency",       required_argument,      0,   'f'    },
    {"help",            no_argument,            0,   255+2  },
    {0,                 0,                      0,   0      }
};


void parse_error(string message = "Try '--help' for more information.")
{
    if(message[message.size()-1] != '\n') message+="\n";
    fprintf(stderr,message.c_str());
    exit(1);
}

string getName(int c)
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
    try
    {
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
    catch (const bf::filesystem_error& ex)
    {
    cout << ex.what() << '\n';
    }
}

bool resetDir(bf::path p)
{
    try
    {
        if(bf::exists(p) && bf::is_directory(p) && !bf::is_empty(p)) {
            char op;
            printf("Remove %s? [y/n]\n", p.c_str());
            cin>>op;
            if(op == 'y')
            bf::remove_all(p);
        }
        if(bf::exists(p) && bf::is_directory(p) && bf::is_empty(p)) return true;
        else if(createDirs(p)) return true;
        else return false;
    }
    catch (const bf::filesystem_error& ex)
    {
    cout << ex.what() << '\n';
    }
}

bool verifyDir(bf::path p)
{
    cout<<endl<<p<<endl;
    try
    {
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
        cout<<"Doesn't exist, do you want to create it? [y/n]"<<endl;
        cin>>op;
        if(op == 'y')
        {
            if(!createDirs(p)) exit(1);
            return true;
        }
        else return false;
    }
    }
    catch (const bf::filesystem_error& ex)
    {
    cout << ex.what() << '\n';
    }
}

bool hasFiles(bf::path p, string ext="")
{
    cout<<endl<<p<<endl;
    try
    {
        if(bf::is_empty(p))
        {
            cout<<"Empty directory"<<endl;
            return false;
        }
        else
        {
//            if(!ext.empty())
//            {
//                uint count = 0;
//                vector<bf::path> v;
//                copy(bf::directory_iterator(p), bf::directory_iterator(), back_inserter(v));
//                sort(v.begin(), v.end());
//                vector<bf::path>::iterator it = v.begin();
//                for(; it != v.end(); it++) if((*it).native().find(ext) != string::npos) count++;
//                cout<<"Has "<<count<<" "<<ext<< " files"<<endl;
//            }
            return true;
        }
    }
    catch (const bf::filesystem_error& ex)
    {
    cout << ex.what() << '\n';
    }
}

vector<boost::filesystem::path> getFilePaths(bf::path directory, string filter="")
{
    vector<bf::path> paths;
    copy(bf::directory_iterator(directory), bf::directory_iterator(), back_inserter(paths));
    sort(paths.begin(), paths.end());
    vector<bf::path>::iterator it = paths.begin();
    //filter by extension
    if(!filter.empty())
    {
        while(it != paths.end())
        {
            if((*it).native().find(filter) == string::npos) paths.erase(it);
            else it++;
        }
    }

    return paths;
}

void updateProgress(int val, int total)
{
    int space = (int) (log10((float) total)+1);
    cout << '\r'
         << "Progress: "
         << setw(space) << setfill('0') << val << "/"
         << setw(space) << setfill('0') << total
         << flush;
}

string pop_slash(string str){
    if(str.back() == '/') str.pop_back();
    return str;
}

int main(int argc, char **argv)
{
    bf::path inDir, outDir;
    string data_folder, sequence;
    float range, frequency=5;
    int width, heigh;

    /*****************************Parser*****************************/
    bool mandatory;
    int c, longindex=0;
    const char *short_opt = "r:w:h:i:s:o:f";
    vector<int> mandatories={ 'r', 'w', 'h', 'i', 's', 'o'};
    vector<int> flags=mandatories;
    ostringstream msg, ostrFile;

    while ((c = getopt_long(argc, argv, short_opt, long_opt, &longindex)) != -1)
    {
        switch (c)
        {
        case 'r':
            range = atof(optarg);
            printf("%s '%f' meters\n", getName(c).c_str(), range);
            break;
        case 'w':
            width = atoi(optarg);
            printf("%s '%i' pixels\n", getName(c).c_str(), width);
            break;
        case 'h':
            heigh = atof(optarg);
            printf("%s '%i' pixels\n", getName(c).c_str(), heigh);
            break;
        case 'i':
            inDir = pop_slash(string(optarg));
            printf("%s '%s'\n", getName(c).c_str(), inDir.c_str());
            break;
        case 's':
            sequence = optarg;
            for(int i=0; i<sequence.size(); i++) if(!isdigit(sequence[i])) parse_error("Invalid sequence number");
            if(sequence.size()==1) sequence.insert(0,"0");
            printf("%s '%s'\n", getName(c).c_str(), sequence.c_str());
            break;
        case 'o':
            outDir = pop_slash(string(optarg));
            printf("%s '%s'\n", getName(c).c_str(), outDir.c_str());
            break;
        case 255+1:
            data_folder = optarg;
            printf("%s '%s'\n", getName(c).c_str(), data_folder.c_str());
            break;
        case 'f':
            frequency = atof(optarg);
            printf("%s '%f'\n", getName(c).c_str(), frequency);
            break;
        case 255+2:
            printf("Usage: %s mandatory [optional]\n", argv[0]);
            printf("\nMandatory args:\n");
            printf(" -r, --range        aproximate maximum lidar range (in meters)\n");
            printf(" -w, --width        width of the generated images in pixels\n");
            printf(" -h, --heigh        heigh of the generated images in pixels\n");
            printf(" -i, --input        beamagine dataset directory\n");
            printf(" -s, --sequence     number of the sequence to convert\n");
            printf(" -o, --output       directory to save the transformed sequence\n");
            printf("\nOptional args:\n");
            printf(" -f, --frequency    scanning frequency of the lidar in Hz {default: %f}\n", frequency);
            printf(" --data             folder name contaning the data (lidar, cameras...)\n");
            printf(" --help             print this help and exit\n\n");
            exit(0);
        default:
            parse_error();
        }

        if(find(mandatories.begin(), mandatories.end(), c) != mandatories.end()) mandatory=true;
        else mandatory = false;

        if(mandatory)
        {
            if((int)distance(remove( flags.begin(), flags.end(), c), flags.end()) > 0) flags.pop_back();
            else parse_error("Repeated mandatory argument: -"+getName(c));
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

    //Set up paths
    bf::path dataDir = pop_slash(inDir.native()+data_folder);
    bf::path lidarPath = dataDir.native()+"/"+sequence;
    bf::path calibPath = dataDir.native()+"/calib.txt";
    bf::path textPath = outDir.native()+"/"+sequence+".txt";

    if(!verifyDir(dataDir) or !hasFiles(dataDir,"")) parse_error();
    if(!verifyDir(lidarPath) or !hasFiles(lidarPath,".pcd")) parse_error();

    if(!verifyDir(outDir)) parse_error("Error creating save path");

    vector<bf::path> pcdPaths = getFilePaths(lidarPath, ".pcd");

    ifstream inCalib(calibPath.c_str());
    //ofstream outCtxt(Ctxt.c_str());
    ofstream outText(textPath.c_str());
    if(!inCalib.good()) parse_error("Error opening file: "+calibPath.native()+"\n");


    //Declare variables
    float X, Y, Z, depthScale, max_act, max_old;
    uint32_t intensity;
    double timestamp = 0;
    int numPts, x, y, f, frames = pcdPaths.size();
    int space = (int) (log10((float) frames)+1);
    uint inside,outside,valid,outOfRangeIntensity, selected;
    string l, num, strFile;
    istringstream line;
    Matrix34f P;
    ei::Matrix3Xf pts;
    Matrix1Xf Dm;
    Matrix1Xu Im;
    ei::Array3Xf ptsP;
    cv::Mat D, I;
    vector<bf::path>::iterator itPcd;
    pcl::PCLPointCloud2 blob;
    pcl::PointCloud<pcl::PointXYZRGB>::Ptr cloud (new pcl::PointCloud<pcl::PointXYZRGB>);


    //Calculate depth sampling per meter
    depthScale = pow(2,16)/range;
    printf("\n\nDepth Scale: %f   (values/meter)\n", depthScale);
    printf("Precision:   %f   (meters)\n\n\n", 1.0/depthScale);


    //Load transformations from calib file
    while(true)
    {
        getline(inCalib, l);
        if(inCalib.eof()) break;
        line.str(l);
        line.clear();
        line>>num;
        if(num[0]=='P')
        {
            for(int i=0; line.good(); i++)
            {
                line>>num;
                P(i/4, i%4) = stof(num);
            }
        }
    }
    inCalib.close();

    //Invert focal_y to flip projection
    P(1,1) = -1*P(1,1);

    selected = 0;
    //For every frame
    for(f = 0, itPcd = pcdPaths.begin(); f<frames; f++, itPcd++)
    {
        updateProgress(f+1, frames);

        //Update timestamp
        timestamp += 1/frequency;

        //Load pointcloud and get XYZI values
        pcl::io::loadPCDFile ((*itPcd).native(), blob);
        pcl::fromPCLPointCloud2 (blob, *cloud);
        numPts = cloud->points.size();
        pts = ei::Matrix3Xf::Zero(3, numPts);
        Im = Matrix1Xu::Zero(1, numPts);
        for (size_t i = 0; i < numPts; ++i)
        {
                X = cloud->points[i].x/1000.0;
                Y = cloud->points[i].y/1000.0;
                Z = cloud->points[i].z/1000.0;
                intensity = *reinterpret_cast<int*>(&(cloud->points[i].rgb));
                pts.col(i) << X, Y, Z;
                Im.col(i) << intensity;
        }

        //Project 3d lidar points and calculate scaled depth
        ptsP=(P*pts.colwise().homogeneous()).array();
        ptsP.rowwise() /= ptsP.row(2);
        Dm=pts.row(2);
        Dm = Dm*depthScale;
        D = cv::Mat::zeros(heigh, width, CV_16UC1);
        I = cv::Mat::zeros(heigh, width, CV_16UC1);
        inside=0, outside=0, valid=0, outOfRangeIntensity=0;
        int32_t di;
        uint16_t d;
        //cout<<"Intensity " << f <<" " <<Im.rowwise().maxCoeff()<<endl;
        for(int i=0; i<Dm.cols(); i++) //iterate depth values
        {
            x = round(ptsP(0,i));
            y = round(ptsP(1,i));

            if(x<width && x>=0 && y<heigh && y>=0) //consider only points projected within camera sensor
            {
                inside +=1;
                di = (int32_t) round(Dm(0,i));
                if(di>0) //only positive depth
                {

                    d = (uint16_t) di;
                    if(d>=pow(2,16) && D.at<uint16_t>(y,x) == 0) D.at<uint16_t>(y,x)=pow(2,16)-1;//exceed established limit (save max)
                    else if(D.at<uint16_t>(y,x) == 0) D.at<uint16_t>(y,x)=d;//pixel without value (save sensed depth)
                    else if(D.at<uint16_t>(y,x) > d) D.at<uint16_t>(y,x)=d;//pow(2,16)-1; //pixel with value (save the smaller depth)
                }

                if(Im(0,i) >= 0 && Im(0,i) < pow(2,32) && f%5 == 0)
                {
                  outText<<Im(0,i)<<";";
                  valid+=1;
                }

                //if(Im(0,i) < 0 || Im(0,i) >= pow(2,24)) outOfRangeIntensity++;
                //else I.at<uint16_t>(y,x) = trunc(((double) Im(0,i) / pow(2,24)) * pow(2,16)); //Re-quantize to 16bit
            }
            else outside+=1;
            //printf(inside+outside); //~94,5K points x scan
        }
        if(f%5 == 0)
        {
          outText<<endl;
          selected++;
          cout<<"SELECTED: "<<selected<<"/12"<<endl;
        }
        if(selected == 12) break;


    }
    outText.close();
    if(selected != 12) exit(1);
}

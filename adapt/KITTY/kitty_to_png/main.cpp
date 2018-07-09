#include <iostream>
#include <math.h>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <sstream>
#include <opencv2/opencv.hpp>
#include <eigen3/Eigen/Core>
#include <eigen3/Eigen/Geometry>
#include <boost/filesystem.hpp>
#include <getopt.h>

using namespace std;
using namespace cv;
namespace bf = boost::filesystem;
namespace ei = Eigen;

typedef ei::Matrix<float, 3, 4> Matrix34f;
typedef ei::Matrix<ushort, 1, ei::Dynamic> Matrix1Xs;
typedef ei::Matrix<float, 1, ei::Dynamic> Matrix1Xf;


static struct option long_opt[] = {
    {"range",           required_argument,      0,   'r'    },
    {"downsampling",    required_argument,      0,   'd'    },
    {"input",           required_argument,      0,   'i'    },
    {"sequence",        required_argument,      0,   's'    },
    {"output",          required_argument,      0,   'o'    },
    {"data",            required_argument,      0,   255+1  },
    {"lidar",           required_argument,      0,   255+2  },
    {"camera",          required_argument,      0,   255+3  },
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
            if(op == 'y') bf::remove_all(p);
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
            if(!ext.empty())
            {
                uint count = 0;
                vector<bf::path> v;
                copy(bf::directory_iterator(p), bf::directory_iterator(), back_inserter(v));
                sort(v.begin(), v.end());
                vector<bf::path>::iterator it = v.begin();
                for(; it != v.end(); it++) if((*it).native().find(ext) != string::npos) count++;
                cout<<"Has "<<count<<" "<<ext<< " files"<<endl;
            }
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

int main(int argc, char **argv)
{
    bf::path inPath, outPath;
    string data_folder = "sequences", lidar_folder = "velodyne", camera_folder = "image_2", sequence;
    float dfactor=1, range;

    /*****************************Parser*****************************/
    bool mandatory;
    int c, longindex=0;
    const char *short_opt = "r:d:i:s:o:h";
    std::vector<int> flags={ 'r', 'd', 'i', 's', 'o'};
    ostringstream msg;
    
    while ((c = getopt_long(argc, argv, short_opt, long_opt, &longindex)) != -1)
    {
        switch (c)
        {
        case 'r':
            range = atof(optarg);
            printf("%s '%f' meters\n", findName(c).c_str(), range);
            break;
        case 'd':
            dfactor = atof(optarg);
            if(dfactor < 1 && dfactor > 0) printf("%s '%f'\n", findName(c).c_str(), dfactor);
            else if(dfactor > 1) {dfactor = 1/dfactor; printf("%s '%f'\n", findName(c).c_str(), dfactor);}
            else if(dfactor == 1) break;
            else parse_error("Invalid downsampling factor\n");
            break;
        case 's':
            sequence = optarg;
            for(int i=0; i<sequence.size(); i++) if(!isdigit(sequence[i])) parse_error("Invalid sequence number\n");
            if(sequence.size()==1) sequence.insert(1,"0");
            printf("%s '%s'\n", findName(c).c_str(), sequence.c_str());
            break;
        case 'i':
            inPath = optarg;
            printf("%s '%s'\n", findName(c).c_str(), inPath.c_str());
            break;
        case 'o':
            outPath = optarg;
            printf("%s '%s'\n", findName(c).c_str(), outPath.c_str());
            break;
        case 255+1:
            data_folder = optarg;
            printf("%s '%s'\n", findName(c).c_str(), data_folder.c_str());
            break;
        case 255+2:
            lidar_folder = optarg;
            printf("%s '%s'\n", findName(c).c_str(), lidar_folder.c_str());
            break;
        case 255+3:
            camera_folder = optarg;
            printf("%s '%s'\n", findName(c).c_str(), camera_folder.c_str());
            break;
        case 'h':
            printf("Usage: %s mandatory [optional]\n", argv[0]);
            printf("\nMandatory args:\n");
            printf(" -r, --range        aproximate maximum lidar range (in meters)\n");
            printf(" -d, --downsampling image downsampling factor (0,1)\n");
            printf(" -i, --input        kitty dataset directory\n");
            printf(" -s, --sequence     number of the sequence to convert\n");
            printf(" -o, --output       directory to save the transformed sequence\n");
            printf("\nOptional args:\n");
            printf(" --data             folder name contaning the data (lidar, cameras...) {default: sequences}\n");
            printf(" --lidar            folder name contaning .bin lidar files {default: velodyne}\n");
            printf(" --camera           folder name contaning .png color images {default: image_2}\n");
            printf(" -h, --help         print this help and exit\n\n");
            exit(0);
        default:
            parse_error();
        }

        if(find(flags.begin(), flags.end(), c) != flags.end()) mandatory=true;
        else mandatory = false;

        if(mandatory)
        {
            if((int)distance(remove( flags.begin(), flags.end(), c), flags.end()) > 0) flags.pop_back();
            else parse_error("Repeated mandatory argument -"+findName(c)+" \n");
        }
    }

    if(flags.size() != 0)
    {
        msg.str("");
        msg<<"Missing: ";
        for( int i = 0; i < flags.size(); i++ )
            msg <<"-"<< (char)flags[i];
        msg<<" (mandatory arguments)\n"<<endl;
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
    bf::path dataPath = inPath.native()+data_folder+"/";
    bf::path lidarPath = dataPath.native()+sequence+"/"+lidar_folder;
    bf::path cameraPath = dataPath.native()+sequence+"/"+camera_folder;
    bf::path calibPath = dataPath.native()+sequence+"/calib.txt";
    bf::path timesPath = dataPath.native()+sequence+"/times.txt";
    
    if(!verifyDir(dataPath) or !hasFiles(dataPath,"")) parse_error();
    if(!verifyDir(lidarPath) or !hasFiles(lidarPath,".bin")) parse_error();
    if(!verifyDir(cameraPath) or !hasFiles(cameraPath,".png")) parse_error();
    
    if(!verifyDir(outPath)) parse_error("Error creating save path\n");
    bf::path outCpath = outPath.native()+sequence+"/rgb/";
    bf::path outDpath = outPath.native()+sequence+"/depth/";
    bf::path outIpath = outPath.native()+sequence+"/intensity/";
    if(!resetDir(outCpath)) exit(1);
    if(!resetDir(outDpath)) exit(1);
    if(!resetDir(outIpath)) exit(1);

    float depthScale = pow(2,16)/range; //calculate depth sampling per meter

    cout<<endl<<endl;
    printf("Depth Scale %f   calculated depth scale (values/meter)\n", depthScale);
    printf("Precision   %f   meters\n\n\n", 1.0/depthScale);

    //load data paths
    vector<bf::path> binPaths = getFilePaths(lidarPath, ".bin");
    vector<bf::path> pngPaths = getFilePaths(cameraPath, ".png");

    //for every pointcloud get XYZI values
    float X,Y,Z,R;
    ei::Matrix3Xf pts;
    Matrix1Xf Im;
    vector<ei::Matrix3Xf> seqPts;
    vector<Matrix1Xf> seqIm;
    streampos begin,end;
    int numPts, i;
    vector<bf::path>::iterator itBin = binPaths.begin();
    for(; itBin != binPaths.end(); itBin++)
    {
        ifstream inLid((*itBin).c_str(), ios::binary);
        if(!inLid.good()) parse_error("Error reading file: "+(*itBin).native()+"\n");
        begin = inLid.tellg();
        inLid.seekg (0, ios::end);
        end = inLid.tellg();
        inLid.seekg(0, ios::beg);
        numPts = (end-begin)/(4*sizeof(float)); //calculate number of points
        pts = ei::Matrix3Xf::Zero(3, numPts);
        Im = Matrix1Xf::Zero(1, numPts);
        for (i=0; i<numPts; i++)
        {
                if(!inLid.good()) parse_error("Error reading file: "+(*itBin).native()+"\n");
                inLid.read((char *) &X, sizeof(float));
                inLid.read((char *) &Y, sizeof(float));
                inLid.read((char *) &Z, sizeof(float));
                inLid.read((char *) &R, sizeof(float));
                pts.col(i) << X, Y, Z;
                Im.col(i) << R;
        }
        seqPts.push_back(pts);
        seqIm.push_back(Im);
        inLid.close();
        cout<<"Loading lidar "<<distance(binPaths.begin(),itBin)+1<<"/"<<binPaths.size()<<endl;
    }

    //Load transformations from calib file
    ifstream incalib(calibPath.c_str());
    if(!incalib.good()) parse_error("Error reading file: "+calibPath.native()+"\n");
    string l, word;
    istringstream line;
    Matrix34f P[4], Tr;
    while(getline(incalib, l))
    {
        line.str(l);
        line.clear();
        line>>word;
        if(word[0]=='P')
        {
            int cam = word[1] - '0';
            for(int i=0; line.good(); i++)
            {
                line>>word;
                P[cam](i/4, i%4) = stof(word);
            }
        }
        else
        {
            for(int i=0; line.good(); i++)
            {
                line>>word;
                Tr(i/4, i%4) = stof(word);
            }
        }
    }
    incalib.close();

    //Load color images
    cv::Mat color;
    vector<cv::Mat> seqColor;
    vector<bf::path>::iterator itPng = pngPaths.begin();
    for(; itPng != pngPaths.end(); itPng++)
    {
        color = cv::imread((*itPng).c_str(), IMREAD_COLOR);
        if(color.empty()) parse_error("Could not open or find the color image: "+(*itPng).native()+"/n");

        //Downsample color images
        if(dfactor != 1) cv::resize(color.clone(), color, Size(), dfactor, dfactor, cv::INTER_LINEAR);
        seqColor.push_back(color.clone());
//        cv::imshow( "Display window", color );
//        cv::waitKey(0);
        cout<<"Loading & downsampling camera image "<<distance(pngPaths.begin(),itPng)+1<<"/"<<pngPaths.size()<<endl;
    }
    int heigh = color.rows;
    int width = color.cols;

    //Save kintinuous calib file
    bf::path kintCalib = outPath.native()+sequence+"/kintinuous_calib.txt";
    ofstream outKintCalib(kintCalib.c_str());
    if(!outKintCalib.good()) parse_error("Error opening kintinuous calib file\n");
    outKintCalib<<P[2](0,0)<<" ";
    outKintCalib<<P[2](1,1)<<" ";
    outKintCalib<<P[2](0,2)<<" ";
    outKintCalib<<P[2](1,2)<<" ";
    outKintCalib<<width<<" ";
    outKintCalib<<heigh<<endl;
    outKintCalib.close();


    //compute x,y and scaled depth
    uint inside=0,outside=0,valid=0;
    cv::Mat D,I;
    int x, y;
    vector<cv::Mat> seqD, seqI;
    Matrix1Xf Dm;
    ei::Array3Xf ptsP2, ptsA;
    vector<ei::Matrix3Xf>::iterator itPts = seqPts.begin();
    vector<Matrix1Xf>::iterator itIm = seqIm.begin();
    for(int i = 1; itPts != seqPts.end(); itPts++, i++, itIm++)
    {
        ptsA = (*itPts).array();
        (*itPts) = ptsA.matrix();
        (*itPts)=Tr*(*itPts).colwise().homogeneous();
        ptsP2=(P[2]*(*itPts).colwise().homogeneous()).array();
        ptsP2.rowwise() /= ptsP2.row(2);
        Dm=(*itPts).row(2);
        Dm = Dm*depthScale;
        ei::Array<float,1,ei::Dynamic> Da = Dm.array();
        Dm = Da.round().matrix();
        D = cv::Mat::zeros(color.size(), CV_16U);
        I = cv::Mat::zeros(color.size(), CV_32F);
        for(int j=0; j<Dm.cols(); j++) //iterate depth values
        {
            x = round(ptsP2(0,j)*dfactor);
            y = round(ptsP2(1,j)*dfactor);

            if(x<width && x>=0 && y<heigh && y>=0) //consider only points projected within camera sensor
            {
                inside ++;
                if(Dm(0,j)>0) //only positive depth
                {
                    valid++;
                    ushort d = (ushort) Dm(0,j);
                    if(d>=pow(2,16) && D.at<ushort>(y,x) == 0) D.at<ushort>(y,x)=pow(2,16)-1;//exceed established limit (save max)
                    else if(D.at<ushort>(y,x) == 0) D.at<ushort>(y,x)=d;//pixel with no value (save sensed depth)
                    else if(D.at<ushort>(y,x) > d) D.at<ushort>(y,x)=d;//pow(2,16)-1; //pixel with value (save the smaller depth)
                }
                I.at<float>(y,x) = (*itIm)(0,j);
            }
            else outside ++;
        }
//        cout<<endl<<endl<< (float)inside/(inside+outside)<<"% inside depths"<<endl; //32%
//        cout<<endl<<endl<< (float)valid/(inside+outside)<<"% inside and valid depths"<<endl; //0.16% !!!

//        //Display
//        cv::imshow( "Display window", D);
//        cv::waitKey(1);

        //####Todo: Interpolate D image??

        seqD.push_back(D.clone());
        seqI.push_back(I.clone());
        cout<<"Projecting 3d lidar points with scaled depth "<<i<<"/"<<seqPts.size()<<endl;
    }


    //Save png images
    vector<cv::Mat>::iterator itD = seqD.begin(), itI = seqI.begin(), itColor = seqColor.begin();
    vector<bf::path>::iterator itPaths = pngPaths.begin();
    ifstream intimes(timesPath.c_str());
    bf::path Ctxt = outPath.native()+sequence+"/rgb.txt";
    bf::path Dtxt = outPath.native()+sequence+"/depth.txt";
    bf::path Itxt = outPath.native()+sequence+"/intensity.txt";
    bf::path Atxt = outPath.native()+sequence+"/associations.txt";
    ofstream outCtxt(Ctxt.c_str());
    ofstream outDtxt(Dtxt.c_str());
    ofstream outItxt(Itxt.c_str());
    ofstream outAtxt(Atxt.c_str());
    if(!intimes.good()) parse_error("Error opening file: " + timesPath.native()+"\n");
    if(!outCtxt.good() || !outDtxt.good() || !outItxt.good() || !outAtxt.good()) parse_error("Error opening txt save files\n");
    float timestamp;
    while(distance(seqD.begin(),itD) < seqD.size())
    {
        getline(intimes, l);
        timestamp = stof(l);

        outCtxt<<timestamp<<" ./rgb/"<<(*itPaths).filename().native()<<endl;
        outDtxt<<timestamp<<" ./depth/"<<(*itPaths).filename().native()<<endl;
        outItxt<<timestamp<<" ./intensity/"<<(*itPaths).filename().native()<<endl;
        outAtxt<<timestamp<<" ./depth/"<<(*itPaths).filename().native()<<" "<<timestamp<<" ./rgb/"<<(*itPaths).filename().native()<<endl;

        color = (*itColor).clone();
        D = (*itD).clone();
        I = (*itI).clone();

//        cv::resize((*itColor).clone(), color, Size(640,480), 0, 0, cv::INTER_LINEAR);
//        cv::resize((*itD).clone(), D, Size(640,480), 0, 0, cv::INTER_LINEAR);
//        cv::resize((*itI).clone(), I, Size(640,480), 0, 0, cv::INTER_LINEAR);

        if(!cv::imwrite(outCpath.native()+(*itPaths).filename().native(), color)) parse_error("Error saving rgb image\n");
        if(!cv::imwrite(outDpath.native()+(*itPaths).filename().native(), D)) parse_error("Error saving depth image\n");
        if(!cv::imwrite(outIpath.native()+(*itPaths).filename().native(), I)) parse_error("Error saving intensity image\n");

        itD++;
        itI++;
        itColor++;
        itPaths++;
        cout<<"Saving color, depth and intensity images "<<distance(seqD.begin(),itD)<<"/"<<seqD.size()<<endl;
    }

    cout<<"Transformation complete!"<<endl;
    cout<<endl<<endl;
    cout<<"width: "<<width<<" heigh: "<<heigh<<endl;
    printf("Depth Scale %f   calculated depth scale (values/meter)\n", depthScale);
    printf("Precision   %f   meters\n\n\n", 1.0/depthScale);

    outCtxt.close();
    outDtxt.close();
    outItxt.close();
    outAtxt.close();

    exit(0);
}


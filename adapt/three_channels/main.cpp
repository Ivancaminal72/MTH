#include <iostream>
#include <math.h>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <sstream>
#include <opencv2/opencv.hpp>

using namespace std;

void showUsage(string p)
{
    printf("\nUsage:\n%s input output\n", p.c_str());
    exit(1);
}

int main(int argc, char * argv[])
{

    /*****************************Parser*****************************/
    if(argc < 3)
    {
        showUsage(argv[0]);
    }
    string inpath = argv[1];
    string outpath = argv[2];

    /*****************************Program*****************************/
    cv::Mat Iori, Imod;
    Iori = cv::imread(inpath.c_str(), cv::IMREAD_UNCHANGED);
    if(Iori.empty()) cout<<"Could not open or find the image: "+inpath<<endl;
    //cout<<Iori.type()<<endl;
    cv::Mat temp[] = {Iori, Iori, Iori};
    cv::merge(temp, 3, Imod);
    //cout<<Imod.type()<<endl;
    if(!cv::imwrite(outpath, Imod)) cout<<"Error saving image"<<endl;

}

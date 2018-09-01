/*
 *
 *  Created on: 21/8/2018
 *      Author: Ivan Caminal
 */

#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <opencv2/opencv.hpp>
#include "utils.h"

void showUsage(string p)
{
    printf("\nUsage:\n"
        "%s mandatories [optionals]\n"
        "Mandatories:\n"
        "   --seq           Sequence Directory\n"
        "   --dat           Data folders containing the images to flip (separated by ',')\n"
        "Optionals:\n"
        "   --out           Output sequence directory (fliped). {Default: SequenceDirectory_fliped}\n"
        "   --help, -h      Show this help\n"
        "\n", p.c_str());
    exit(1);
}

int main(int argc, char * argv[])
{
    bf::path seqDir, actDir, outDir, outDatDir;
    std::vector<std::string> folders;
    bool seqisout = true;

    /*****************************Parser*****************************/
    if(argc < 1+(2*2))
    {
        showUsage(argv[0]);
    }

    for(int i=1; i<argc; ++i)
    {
        if(std::strcmp(argv[i], "--out") == 0)
        {
            outDir = pop_slash(string(argv[++i]));
            seqisout=false;
        }
        else if(std::strcmp(argv[i], "--dat") == 0)
        {
            boost::split(folders, argv[++i], boost::is_any_of(","), boost::token_compress_on);
        }
        else if(std::strcmp(argv[i], "--seq") == 0)
        {
            seqDir = pop_slash(string(argv[++i]));
        }
        else if(std::strcmp(argv[i], "--help") == 0 || std::strcmp(argv[i], "-h") == 0 )
        {
            showUsage(argv[0]);
        }
    }

    /*****************************Program*****************************/

    //Verify all data dirs
    for(auto const folder : folders)
    {
        actDir = seqDir.native()+"/"+folder;
        if(!verifyDir(actDir) or !hasFiles(actDir,".png")) exit(1);
    }

    vector<bf::path> pngPaths;
    cv::Mat Iori, Iflip;
    unsigned i;

    //Do flip
    for(const auto &folder : folders)
    {
        actDir = seqDir.native()+"/"+folder;
        if(!verifyDir(actDir) or !hasFiles(actDir,".png")) exit(1);
        pngPaths = getFilePaths(actDir, ".png");
        if(outDir.native().empty()) outDatDir = seqDir.native()+"_flip/"+folder;
        else {outDatDir = seqDir.native()+"/"+folder;}
        if(!resetDir(outDatDir)) exit(1);

        i=0;
        printf("Folder: %s\n", folder.c_str());

        for(auto const &pngPath : pngPaths)
        {
            //Load image
            i+=1;
            updateProgress(i, pngPaths.size());
            Iori = cv::imread(pngPath.c_str(), cv::IMREAD_UNCHANGED);
            if(Iori.empty()) parse_error("Could not open or find the image: "+pngPath.native()+"\n");
            Iflip = cv::Mat::zeros(Iori.size(), Iori.type());
            cv::flip(Iori, Iflip, 0);
            if(!cv::imwrite(outDatDir.native()+"/"+pngPath.filename().native(), Iflip)) parse_error("Error saving image");
        }
    }

}



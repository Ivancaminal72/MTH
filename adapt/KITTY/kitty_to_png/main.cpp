#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <sstream>
//#include <opencv2/opencv.hpp>
#include <boost/filesystem.hpp>
#include <getopt.h>

namespace bf = boost::filesystem;

int main(int argc, char **argv)
{
    if (argc == 1)
    {
        printf("Try `%s --help' for more information.\n", argv[0]);
        exit(1);
    }

    bf::path lidarPath, imagePath;
    float scaling, downsampling;

    /*****************************Parser*****************************/
    int c, longindex=0;
    const char *short_opt = "s:d:l:i:h";
    static struct option long_opt[] = {
        {"scaling",         required_argument,      0,   's' },
        {"downsampling",    required_argument,      0,   'd' },
        {"lidar",           required_argument,      0,   'l' },
        {"image",           required_argument,      0,   'i' },
        {"help",            no_argument,            0,   'h' },
        {0,                 0,                      0,   0   }
    };

    while ((c = getopt_long(argc, argv, short_opt, long_opt, &longindex)) != -1)
    {
        switch (c)
        {
        case 's':
            scaling = atof(optarg);
            printf("scaling '%f'\n", scaling);
            break;
        case 'd':
            downsampling = atof(optarg);
            printf("downsampling '%f'\n", downsampling);
            break;
        case 'l':
            lidarPath = optarg;
            printf("lidar '%s'\n", lidarPath.c_str());
            break;
        case 'i':
            imagePath = optarg;
            printf("image '%s'\n", imagePath.c_str());
            break;
        case 'h':
            printf("Usage: %s mandatory [optional]\n", argv[0]);
            printf("\nMandatory args:\n");
            printf(" -s, --scaling      depth scaling factor\n");
            printf(" -d, --downsampling image downsampling factor\n");
            printf(" -l, --lidar        lidar sequence directory\n");
            printf("\nOptional args:\n");
            printf(" -i, --image        image sequence directory (default: lidar dir.\n");
            printf(" -h, --help         print this help and exit\n\n");
            exit(0);
        default:
            printf("Try `%s --help' for more information.\n", argv[0]);
            exit(1);
        }
    }

    if(is_empty(imagePath)) imagePath = lidarPath;
    if (optind < argc)
    {
        printf("non-option ARGV-elements: ");
        while (optind < argc)
            printf("%s \n", argv[optind++]);
    }

    /*****************************Program*****************************/



    exit(0);
}


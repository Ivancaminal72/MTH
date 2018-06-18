#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <sstream>
//#include <opencv2/opencv.hpp>
#include <boost/filesystem.hpp>
#include <getopt.h>

namespace bf = boost::filesystem;

void parse_error()
{
    printf("Try `%s --help' for more information.\n", argv[0]);
    exit(1);
}

int main(int argc, char **argv)
{
    if (argc == 1) parse_error();

    bf::path lidarPath, imagePath;
    float scaling, downsampling;

    /*****************************Parser*****************************/
    int c, longindex=0;
    const char *short_opt = "l:s:i::h";
    static struct option long_opt[] = {
        {"scaling",         required_argument,      0,   255+1  },
        {"downsampling",    required_argument,      0,   255+2  },
        {"lidar",           required_argument,      0,   'l'    },
        {"save",            required_argument,      0,   's'    },
        {"image",           optional_argument,      0,   'i'    },
        {"help",            no_argument,            0,   'h'    },
        {0,                 0,                      0,   0      }
    };

    while ((c = getopt_long(argc, argv, short_opt, long_opt, &longindex)) != -1)
    {
        switch (c)
        {
        case 255+1:
            scaling = atof(optarg);
            printf("scaling '%f'\n", scaling);
            break;
        case 255+2:
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

    if (optind < argc)
    {
        printf("non-option ARGV-elements: ");
        while (optind < argc)
            printf("%s \n", argv[optind++]);
        parse_error();
    }

    if(is_empty(imagePath)) imagePath = lidarPath;

    /*****************************Program*****************************/



    exit(0);
}


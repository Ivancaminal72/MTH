/*
 *
 *  Created on: 15/7/2018
 *      Author: Ivan Caminal
 */


#include <iostream>
#include <math.h>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <sstream>
#include <boost/filesystem.hpp>
#include <getopt.h>

using namespace std;
namespace bf = boost::filesystem;

static struct option long_opt[] = {
    {"input",           required_argument,      0,   'i'    },
    {"output",          required_argument,      0,   'o'    },
    {"timestamps",      required_argument,      0,   't'    },
    {"help",            no_argument,            0,   'h'    },
    {0,                 0,                      0,   0      }
};

void parse_error(string message = "Try '--help' for more information")
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

int main(int argc, char **argv)
{
    bf::path inPath, outPath, tsPath;

    /*****************************Parser*****************************/
    bool mandatory;
    int c, longindex=0;
    const char *short_opt = "i:o:t:h";
    std::vector<int> mandatories={'i', 'o', 't'};
    std::vector<int> flags = mandatories;
    ostringstream msg;

    while ((c = getopt_long(argc, argv, short_opt, long_opt, &longindex)) != -1)
    {
        switch (c)
        {
        case 'i':
            inPath = optarg;
            printf("%s '%s'\n", getName(c).c_str(), inPath.c_str());
            break;
        case 'o':
            outPath = optarg;
            printf("%s '%s'\n", getName(c).c_str(), outPath.c_str());
            break;
        case 't':
            tsPath = optarg;
            printf("%s '%s'\n", getName(c).c_str(), tsPath.c_str());
            break;
        case 'h':
            printf("Usage: %s mandatory [optional]\n", argv[0]);
            printf("\nMandatory args:\n");
            printf(" -i, --input        path to read the kitty gt poses file\n");
            printf(" -o, --output       path to save the transformed freiburg file\n");
            printf(" -t, --timestamps   path to read the timestamps file\n");
            printf("\nOptional args:\n");
            printf(" -h, --help         print this help and exit\n\n");
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




    exit(0);
}

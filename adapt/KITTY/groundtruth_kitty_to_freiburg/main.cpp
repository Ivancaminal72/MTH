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

void parse_error(string message = "Try '--help' for more information.\n")
{
    fprintf(stderr,message.c_str());
    exit(1);
}

int main(int argc, char **argv)
{
    bf::path inPath, outPath;

    /*****************************Parser*****************************/
    bool mandatory;
    int c;
    const char *short_opt = "i:o:";
    std::vector<int> flags={ 'i', 'o'};
    ostringstream msg;

    while ((c = getopt(argc, argv, short_opt)) != -1)
    {
        switch (c)
        {
        case 'i':
            inPath = optarg;
            printf("%s '%s'\n", findName(c).c_str(), inPath.c_str());
            break;
        case 'o':
            outPath = optarg;
            printf("%s '%s'\n", findName(c).c_str(), outPath.c_str());
            break;
        case 'h':
            printf("Usage: %s mandatory [optional]\n", argv[0]);
            printf("\nMandatory args:\n");
            printf(" -i, --input        path to read the kitty gt poses file\n");
            printf(" -o, --output       path to save the transformed freiburg file\n");
            printf("\nOptional args:\n");
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
            else parse_error("Repeated mandatory argument -"+(char) c+" \n");
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






    exit(0);
}

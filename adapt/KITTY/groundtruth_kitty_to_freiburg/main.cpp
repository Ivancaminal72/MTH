/*
 *
 *  Created on: 15/7/2018
 *      Author: Ivan Caminal
 */


#include <iostream>
#include <iomanip>
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

bool verifyFile(bf::path p)
{
    cout<<endl<<p<<endl;
    try
    {
        if(bf::exists(p))
        {
            if(bf::is_regular_file(p))
            {
                cout<<"Correct file"<<endl;
                return true;
            }
            else
            {
                cout<<"Is not a regular file"<<endl;
                return false;
            }
        }
        else return false;
    }
    catch (const bf::filesystem_error& ex)
    {
    cout << ex.what() << '\n';
    }
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
    if(!verifyFile(inPath)) parse_error();
    if(!verifyFile(tsPath)) parse_error();

    ifstream inFile(inPath.c_str());
    ifstream tsFile(tsPath.c_str());
    ofstream outFile(outPath.c_str());
    if(!inFile.good()) parse_error("Error opening file: "+inPath.native()+"\n");
    if(!tsFile.good()) parse_error("Error opening file: "+tsPath.native()+"\n");
    if(!outFile.good()) parse_error("Error opening file: "+outPath.native()+"\n");

    istringstream line;
    string l, num;
    float ts, m[12], q[4];

    while(true)
    {
        //Read timestamp
        getline(tsFile, num);
        if(tsFile.eof()) break;
        ts = stof(num);

        //Read kitty format
        getline(inFile, l);
        line.str(l);
        line.clear();
        line>>num;
        for(int i=0; i < 12; i++)
        {
            line>>num;
            m[i]= stof(num);
        }

        //Represent rotation matrix as unit quaternion
        q[0] = 0.5*sqrt(1+m[0]+m[5]+m[10]);
        q[1] = (m[9]-m[6])/4*q[0];
        q[2] = (m[2]-m[8])/4*q[0];
        q[3] = (m[4]-m[1])/4*q[0];

        //Write freiburg format
        stringstream strs;
        strs << setprecision(6) << fixed << ts;
        outFile<<strs.str()<<" "<<m[3]<<" "<<m[7]<<" "<<m[11]<<" ";
        outFile<<q[0]<<" "<<q[1]<<" "<<q[2]<<" "<<q[3]<< "\n";

    }
    inFile.close();
    outFile.close();
    tsFile.close();

    cout<<endl<<endl<<"Transformation complete!"<<endl;
}

/*
 *
 *  Created on: 21/8/2018
 *      Author: Ivan Caminal
 */

#include "utils.h"

void parse_error(string message)
{
    if(message[message.size()-1] != '\n') message+="\n";
    fprintf(stderr,message.c_str());
    exit(1);
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

bool hasFiles(bf::path p, string ext)
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

vector<bf::path> getFilePaths(bf::path directory, string filter)
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

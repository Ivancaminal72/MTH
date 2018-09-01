/*
 *
 *  Created on: 21/8/2018
 *      Author: Ivan Caminal
 */

#ifndef UTILS
#define UTILS

#include <iostream>
#include <iomanip>
#include <math.h>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <sstream>
#include <boost/filesystem.hpp>

namespace bf = boost::filesystem;
using namespace std;

void parse_error(string message = "Try '--help' for more information.");
void updateProgress(int val, int total);

string pop_slash(string str);
string getName(int c);

bool createDirs(bf::path p);
bool resetDir(bf::path p);
bool verifyDir(bf::path p);
bool hasFiles(bf::path p, string ext="");

vector<bf::path> getFilePaths(bf::path directory, string filter="");

#endif // UTILS

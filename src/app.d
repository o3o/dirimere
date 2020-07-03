/*
 *   Copyright (c) 2020 Orfeo Da Vià
 *
 *   Boost Software License - Version 1.0 - August 17th, 2003
 *
 *   Permission is hereby granted, free of charge, to any person or organization
 *   obtaining a copy of the software and accompanying documentation covered by
 *   this license (the "Software") to use, reproduce, display, distribute,
 *   execute, and transmit the Software, and to prepare derivative works of the
 *   Software, and to permit third-parties to whom the Software is furnished to
 *   do so, all subject to the following:
 *
 *   The copyright notices in the Software and this entire statement, including
 *   the above license grant, this restriction and the following disclaimer,
 *   must be included in all copies of the Software, in whole or in part, and
 *   all derivative works of the Software, unless such copies or derivative
 *   works are solely in the form of machine-executable object code generated by
 *   a source language processor.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *   FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
 *   SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
 *   FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 *   ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *   DEALINGS IN THE SOFTWARE.
 */

module app;

import std.stdio : writefln, writeln;
import std.experimental.logger;
import std.json : JSONValue;

enum MIRROR = "./.dirimere";

void main(string[] args) {
   import std.getopt;

   bool verbose;
   bool clean;
   string proxyFile = "dirimere.json";

   auto opt = getopt(args, "verbose|v", "Verbose", &verbose,
         "clean|c", "Delete package directory", &clean,
         "proxyFile|i", "The filename of the file to search packages in", &proxyFile,
         );
   if (verbose) {
      globalLogLevel(LogLevel.trace);
   } else {
      globalLogLevel(LogLevel.info);
   }
   if (opt.helpWanted) {
      defaultGetoptPrinter("dirimere", opt.options);
      help;
   } else {
      JSONValue j = makeJson(proxyFile);
      trace(j);
      run(j, clean);
   }
}

JSONValue makeJson(string fn) {
   import std.file : readText;
   import std.json : parseJSON;
   string depJ = readText(fn);
   return parseJSON(depJ);
}

void run(JSONValue dubConfig, bool clean) {
   import std.array : join;
   import std.file : exists, mkdirRecurse, rmdirRecurse;
   import std.process : execute;

   foreach (dep; dubConfig.array) {
      string v = dep["version"].get!string.getVersion;
      string name = dep["name"].get!string;
      string f = getFolderName(name, v);
      if (clean) {
         writefln("Remove %s", f);
         f.rmdirRecurse;
      }

      if (!exists(f)) {
         f.mkdirRecurse;

         string[] cmd = getCloneCmd(dep["url"].get!string, v, f);
         trace(cmd.join(" "));
         writefln("Clone %s version %s", name, v);

         auto reply = execute(cmd);
         if (reply.status != 0) {
            writeln("Failed\n", reply.output);
         } else {
            writeln("Successful");
         }
      } else {
         writeln("None to do");
      }
   }
}

string getVersion(string v) {
   import std.string : startsWith;
   if (v.startsWith("v")) {
      return v[1 .. $];
   } else {
      return v;
   }
}

unittest {
   assert("v1.2.3".getVersion == "1.2.3");
   assert("2.2.3".getVersion == "2.2.3");
}

string getFolderName(string name, string v) {
   import std.path : buildPath;

   return buildPath(MIRROR, name ~ "-" ~ v);
}

unittest {
   string f = getFolderName("cul", "0.1.0");
   assert(f == "./.mirror/cul-0.1.0", f);
}

string[] getCloneCmd(string url, string branch, string folder) {
   string[] a = ["git", "clone", "--depth", "1"];
   a ~= "--branch";
   a ~= "v" ~ branch;
   a ~= url;
   a ~= folder;

   return a;
}

unittest {
   string[] x = getCloneCmd("git@o30", "0.13.0", "cul");
   assert(x[0] == "git");
   assert(x[5] == "v0.13.0");
}


bool isValidCsFile(in string fn) {
   import std.algorithm.searching : canFind;
   enum ASSEMBLY = "Assembly";
   enum TEST = "test";
   enum APP = "App";
   return !(canFind(fn, ASSEMBLY) || canFind(fn, TEST) || canFind(fn, APP));
}
unittest {
   assert(isValidCsFile(".mirror/Uns/src/Cul.cs"));
   assert(!isValidCsFile(".mirror/Uns/src/App.cs"));
   assert(!isValidCsFile(".mirror/Uns/src/AssemblyInfo.cs"));
   assert(!isValidCsFile(".mirror/Uns/src/IAssemblyInfo.cs"));
   assert(!isValidCsFile(".mirror/Uns/test/Cul.cs"));
   assert(!isValidCsFile(".mirror/Uns/tests/Cul.cs"));
}

void help() {
   enum VERSION = "0.5.0";
   writefln("Version %s", VERSION);
}

SimpleClient.tcl is a Tcl script that implements a very simple client for R
socket server.

Launch R and start a R socket server:

> library(svSocket)
Loading required package: tcltk
Loading Tcl/Tk interface ... done
> startSocketServer()
[1] TRUE

Then launch the client in a console window navigate to the /etc subdirectory
of you svSocket R package installation (where you have found this ReadMe.txt
file), and then, issue the following command:

$ cd [your_path_here]/library/svSocket/etc/
$ tclsh SimpleClient.tcl

Follow instructions: you can type R commands in the console of the client
application and R returns the results of the calculation. You have no command
line edition, and no command history, but you can test various R commands
by typing them in the client or pasting them one by one.

To get something closer to a real console, you should display the prompt and
enable multiline mode. You achieve this by configuring the client with:

parSocket(<<<s>>>, bare = FALSE)

Experiment various R code in this console. Also, you can turn echo on/off of
your commands and the output to the regular R console with:

parSocket(<<<s>>>, echo = TRUE)

You can connect simultaneously as many clients as you like, but you can only
connect local clients for the moment. This is a restriction very easy to
eliminate, but we need to install protection (password access, crypting of the
data) before doing so (planned for the future).

There is a prototype secure version too. Make sure the 'tls' Tcl package is
installed on the server side. Then, in an R pocess, run:

> library(svSocket)
Loading required package: tcltk
Loading Tcl/Tk interface ... done
> startSocketServer(secure = TRUE)
[1] TRUE

Then, you can connect from a separate console to this secure server using the
modified version:

$ cd [your_path_here]/library/svSocket/etc/
$ tclsh SimpleClientSecure.tcl

You have also another prototype client for Mozilla applications (Firefox,
Thunderbird, Komodo, etc.) in development. See ?koCmd in the svIDE package to
learn how to install and use it. Once you have installed the 'SciViews x.y'
toolbox folder in Komodo, go to 'SciViews x.y/Communication/Socket client'. If
the R socket server is started on the same machine as explaned here above,
double clicking on this macro triggers some code in R that asks for the syntax
of the 'library()' function, and then, disconnect immediately. The result is
printed in the 'Command Output' panel in Komodo (open the panel at the bottom
if necessary). This is just a proof-of-concept for the moment.

Enjoy!

Note: tclsh is part of any Tcl distribution. However, it is not provided with
the minimalist Tcl distribution installed by default with R under Windows. To
get tclsh, install the free standard edition of ActiveTcl
(http://www.activestate.com/Products/activetcl/) on this platform. The directory
where tclsh.exe is located must be in the path (done automatically by ActiveTcl
installer, but you probably need to restart windows after installation).

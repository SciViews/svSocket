# svSocket To Do list

- Rework the mechanism to add history item to R from within Komodo.

- Easy redefinition of `options(width = ...)` to adjust width of output to the GUI client R console.

- Make use of a config file for the server + `parSocketServer()` to change (some!) parameters of the server.

- Translation of all messages in the package.

- Delete `SocketClient_xxxx` on disconnection + make sure they are all deleted on server stopping and on package detaching (in `.Last.lib()`).

- `sourcePart()` function sourcing only from line X to line Y in a file!

- Send a command to the regular command line.

- Silent mode (interesting with `echo = TRUE`).

- Correct little glitches with multiline mode and empty lines.

- A mode that flags various parts of output.

- Unattended messages should be printed above command line.

- Allow for remote connection + security? Use a tcl list:

    % set xxxx_allow [list]
    % llength $xxxx_allow
    % lappend xxxx_allow "194.127.34.1"
    % lindex $xxxx_allow 0
    hiking
    % lindex $user_preferences 1
    biking
    % lindex $user_preferences 2
    whale watching
    % lindex $user_preferences 3
    % lindex $user_preferences 5
    % # Before we test:
    % lappend xxxx_allow "127.0.0.1"
    if { [lsearch -exact $xxxx_allow $addr] != -1 } {
        # the address is the allowed list
    }

- Implement a way to interrupt from the remote console + correct `<<<esc>>>`.

- Manage buffered output with `flush.console()`!

- Redirect `stdin()` so that `scan()`, etc.

- For multiline commands, do number them.

- `<<<E>>>` with addition of the command in the R command history.

- Check and solve possible clash when several clients submit commands at the same time.

## Differences between CLI and processSocket()

Tested with R 2.6.1 and testCLIcmd.r v. 1.0-0

- When successive commands are issued and the last one is incomplete like:

    > search(); log(

`processSocket()` waits for a complete last command before processing everything while other consoles process all the commands and then wait for last one to be completed (should be considered as a feature).

- Same problem with multiple instructions send at once when there is an error:
  the first few correct instructions before the error should be evaluated, while
  they are not with `processSocket()` (considered as a feature). Compare this:

    > search(); log)

- For long calculations, `processSocket()` acts as a buffered console (like RGui) except that it does not understand (yet) `flush.console()`!

- There are sometimes cosmetic differences in the way warnings are printed (essentially, truncation of call argument). For instance:

   > options(warn = 0)
   > (function() {warning("Warn!"); 1:3})()

- There are slight differences in the way the error message is presented when
incorrect code is processed. Moreover, R.app (Macintosh) does not print a
descriptive error message, but only "syntax error". This is an old behaviour
that remains only in R.app (among all tested consoles).

- R.app (Macintosh) always print prompts at the beginning of a line. So, `cat("text")` does not produce exactly the same result as in many other consoles including with `processSocket()` (should be considered wrong in R.app!).

- R.app (Macintosh) incorrectly prints a continuation prompt after:

    > options(warn = 2)
    > (function() {warning("Warn!"); 1:3})()

- R.app (Macintosh) does not interpret `\\a` and `\\b` on the contrary to most other consoles. With `processSocket()`, it is the client that must decide how to interpret special characters. Most important ones are: `\\a` => sound a bip and print nothing, `\\b` = backspace, erase previous character, except if at the beginning of a line, `\\t` = tabulation (4 spaces), `\\n` = newline, `\\r` = same as `\\n` (but not interpreted on RGui), `\\r\n` = same as `\\n`, `\\r\\r` and `\\n\\r` are equivalent to `\\n\\n` (for portability) from one platform to the other. `\\f` and `\\v` are interpreted as `\\n` (but not on RGui under Windows), `\\u` and `\\x` are also recognized but interpreted differently from one to the other console, as well as the other exotic escape sequences. It is better to ignore them, or to print a question mark instead.

- Regarding internationalization of error messages, there are two differences between messages at the CLI and issued by processSocket().

- Warning message(s): is not translated at CLI bu it is translated by `processSocket()` (bug?) in:

    > options(warn = 0)
    > warning("Warn!")

- On the contrary, `processSocket()` fails to translate 'Error in' for most
  error messages, and I don't understand this bug:

    > cos("a")

- If you define `options(warning.expression)`, there will be a problem because `processSocket()` redefines it also, and thus, at best, you expression is ignored (must fix this!).

- On the MacOS X, there are many mismatches for string translation, both at the command line and using `processSocket()`, but they are not same mismatches!

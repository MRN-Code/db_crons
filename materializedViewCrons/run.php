<?php

/**
 * Script to run other scripts that manage/refresh materialized views on our postgres dbs
 * Author: Dylan Wood
 * Date: 01/24/2015
 */

require_once('lib/ExclusiveLock.php');
// Environment Config
set_time_limit(4 * 60 * 60); //time limit of four hours
ini_set('error_log', 'syslog'); //send errors to syslog (/var/log/messages);
if (in_array('debug', $argv)) {
    writeLn ('running in debug mode: Errors will be written to stdout');
    ini_set('display_errors', 1);
    ini_set('error_log', ''); //send errors to syslog (/var/log/messages);
}
// Constants
DEFINE('ADMIN_EMAIL', 'nidev@mrn.org,dwood@mrn.org,dlandis@mrn.org');
DEFINE('LOCK_KEY', 'materializedViewCron');


/**
 *
 * Main function. This runs the scripts in series
 */
function run () {
    $scripts = array('tasks/dataExchange/updateOptionsCron.sh', 'tasks/updateCoinsMetrics.sh');
    // first, attempt to get lock
    $lock = getLock();
    // getLock will throw exceptions if it fails to acquire the lock, so we can proceed if none were thrown
    foreach ($scripts as $scriptPath) {
        runScript($scriptPath);
    }
    error_log(__FILE__ . " Successfully ran " . sizeof($scripts) . " scripts. Exiting");
    return;
}


// Utility Functions

/**
 * runScript
 * execute the bash script at the given path
 * if the exec returns a non-zero code, an email will be sent, and an error will be thrown.
 */
function runScript ($scriptPath) {
    $scriptPath = resolveRelativePath($scriptPath);
    $start = microtime(true);
    // redirect stderr to stdout so that php's exec() will capture it
    $execStr = $scriptPath . ' 2>&1';
    // execute the shell script
    $lastLine = exec($execStr, $output, $code);
    // calculate time to execute script
    $seconds = round((microtime(true) - $start));
    // test if there was an error
    if ($code !== 0) {
         // concatenate all stdout that was captured into a single string
         $outputStr = implode($output, PHP_EOL);
         $subject = "FAILURE: Materialized View Cron Exec Error: $code";
         $message = "Attempt to exec `$scriptPath` returned code `$code` exec stdout & stderr: `$outputStr`";
         sendEmail($subject, $message);
         throw new Exception(__FILE__ . $subject);
    }
    error_log(__FILE__ . " Sucessfully ran $scriptPath in $seconds seconds"); 
}

/**
 * getLock
 * Attempt to get a non-blocking lock. This will prevent this script from being called again before it finishes
 * If the lock cannot be acquired, an email is sent and an error is thrown
 */
function getLock ()
{
    try {
        $lock = new ExclusiveLock(resolveRelativePath(LOCK_KEY), false); //retrieve non-blocking lock
    } catch (Exception $e) {
        $subject = "FAILURE: Materialized View Cron Could Not Get Lock: " . $e->getMessage();
        $message = "
            Attempted to run " . __FILE__ . ", but could not open the lock file." . PHP_EOL .
            " Error message: " . PHP_EOL .
            $e->getMessage() . PHP_EOL .
            "This is a FATAL ERROR, and should be resolved immediately";

        sendEmail($subject, $message);
        throw $e;
    }
    if ($lock->lock() === false) {
        $subject = "FAILURE: Materialized View Cron Still Locked";
        $message = "
            Attempted to run " . __FILE__ . ", but the lock was still locked. " . PHP_EOL .
            "This could be caused if the process from the last time the cron-job " .
            "ran is still running." . PHP_EOL .
            "If this is the first time you are receiving this message, then no action may be necessary." . PHP_EOL .
            "This script will be run again by cron, and the lock will be re-checked." . PHP_EOL . PHP_EOL .
            "However, if this email has been received multiple times, then the cron is taking too long to exeute, and should be re-optimized.";
            
        sendEmail($subject, $message);
        throw new Exception(__FILE__ . ": " . $subject); 
    } else {
        error_log(__FILE__ . ' Lock acquired');
        return $lock;
    }
}

/**
 * Send an email to the administrators
 * @param $subject {string} the subject of the email.
 * @param $message {string} the body of the email. Will have the name of this file appended to the end.
 */
function sendEmail ($subject, $body) {
    $body = $body . PHP_EOL . PHP_EOL . "Email sent from " . __FILE__ . PHP_EOL;
    error_log('Attempting to send mail from ' . __FILE__);
    $result = mail(ADMIN_EMAIL, $subject, $body);
    if ($result) {
       error_log('Sent mail successfully from ' . __FILE__);
       error_log('Mail Subject: ' . $subject);
    } else {
        error_log('Sending mail from ' . __FILE__ . ' failed');
        error_log('Mail Subject: ' . $subject);
    }
}

/**
 * Takes a relative path (relative to the current script)
 * Returns an absolute path
 */
function resolveRelativePath($path) {
    return realpath(dirname(__FILE__) . '/' . $path);
}

/**
 * simple helper function to write a line to stdout;
 */
function writeLn ($message) {
    echo $message . PHP_EOL;
}

run();

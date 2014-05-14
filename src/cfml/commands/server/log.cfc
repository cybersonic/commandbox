/**
 * Show server log
 **/
component persistent="false" extends="commandbox.system.BaseCommand" excludeFromHelp=false {

	/**
	 * Show log
	 *
	 * @directory.hint web root for the server
	 * @name.hint short name for the server
	 **/
	function run(String directory="", String name="")  {
		var manager = new commandbox.system.ServerManager(shell);
		var webroot = directory is "" ? shell.pwd() : directory;
		var serverInfo = manager.getServerInfo(fileSystemUtil.resolveDirectory( webroot ));
		var logfile = serverInfo.logdir & "/server.out.txt";
		if(fileExists(logfile)) {
			return fileRead(logfile);
		} else {
			return "No log found";
		}
	}

}
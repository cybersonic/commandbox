/**
* Create a new model CFC in an existing ColdBox application.  Make sure you are running this command in the root
* of your app for it to find the correct folder.  You can optionally create unit tests for your new model at the same time.
* By default, your new model will be created in /model but you can override that with the directory param.
* Once you create a model you can add a mapping for it in your WireBox binder, or use ColdBox's default scan location and
* just reference it with getModel( 'modelName' ).
* .
* {code:bash}
* coldbox create model myModel --open
* {code}
*
 **/
component extends='commandbox.system.BaseCommand' aliases='' excludeFromHelp=false {

	/**
	* Constructor
	*/
	function init(){
		super.init();
		// valid persistences
		variables.validPersistences = 'Transient,Singleton';

		return this;
	}

	/**
	* @name.hint Name of the model to create without the .cfc. For packages, specify name as 'myPackage/myModel'
	* @methods.hint A comma-delimited list of method stubs to generate for you
	* @persistence.hint Specify singleton to have only one instance of this model created
	* @persistence.options Transient,Singleton
	* @tests.hint Generate the unit test BDD component
	* @testsDirectory.hint Your unit tests directory. Only used if tests is true
	* @directory.hint The base directory to create your model in and creates the directory if it does not exist.
	* @script.hint Generate content in script markup or tag markup
	* @description.hint The model hint description
	* @open.hint Open the file once generated
	**/
	function run( 
		required name,
		methods="",
		persistence='transient',
		boolean tests=true,
		testsDirectory='tests/specs/unit',
		directory='models',
		boolean script=true,
		description="I am a new Model Object",
		boolean open=false
	) {
		// This will make each directory canonical and absolute
		arguments.directory 		= fileSystemUtil.resolvePath( arguments.directory );
		arguments.testsDirectory 	= fileSystemUtil.resolvePath( arguments.testsDirectory );

		// Validate directory
		if( !directoryExists( arguments.directory ) ) {
			directoryCreate( arguments.directory );
		}
		// Validate persistence
		if( !listFindNoCase( variables.validPersistences, arguments.persistence ) ) {
			error( "The persistence value [#arguments.persistence#] is invalid. Valid values are [#listChangeDelims( variables.validPersistences, ', ', ',' )#]" );
		}
		// Exit the command if something above failed
		if( hasError() ) {
			return;
		}

		// Allow dot-delimited paths
		arguments.name = replace( arguments.name, '.', '/', 'all' );
		// This help readability so the success messages aren't up against the previous command line
		print.line();

		// Script?
		var scriptPrefix = '';
		// TODO: Pull this from box.json
		if( arguments.script ) {
			scriptPrefix = 'Script';
		}

		// Read in Template
		var modelContent 	 		= fileRead( '/commandbox/templates/ModelContent#scriptPrefix#.txt' );
		var modelMethodContent 		= fileRead( '/commandbox/templates/ModelMethodContent#scriptPrefix#.txt' );
		var modelTestContent 		= fileRead( '/commandbox/templates/testing/ModelBDDContent#scriptPrefix#.txt' );
		var modelTestMethodContent 	= fileRead( '/commandbox/templates/testing/ModelBDDMethodContent#scriptPrefix#.txt' );


		// Basic replacements
		modelContent 	 = replaceNoCase( modelContent, '|modelName|', listLast( arguments.name, '/\' ), 'all' );
		modelContent 	 = replaceNoCase( modelContent, '|modelDescription|', arguments.description, 'all' );
		modelTestContent = replaceNoCase( modelTestContent, '|modelName|', listChangeDelims( arguments.name, '.', '/\' ), 'all' );
		
		// Persistence
		switch ( Persistence ) {
			case 'Transient' :
				modelContent = replaceNoCase( modelContent, '|modelPersistence|', '', 'all' );
				break;
			case 'Singleton' :
				modelContent = replaceNoCase( modelContent, '|modelPersistence|', 'singleton', 'all');
		}

		// Handle Methods
		if( len( arguments.methods ) ){
			var allMethods 		= "";
			var allTestsCases   = "";
			var methodContent 	= "";

			// Loop Over methods to generate them
			for( var thisMethod in listToArray( arguments.methods ) ) {
				thisMethod = trim( thisMethod );
				allMethods = allMethods & replaceNoCase( modelMethodContent, '|method|', thisMethod, 'all' ) & cr & cr;

				print.yellowLine( "Generated method: #thisMethod#");

				// Are we creating tests cases on methods
				if( arguments.tests ) {
					var thisTestCase = replaceNoCase( modelTestMethodContent, '|method|', thisMethod, 'all' );
					allTestsCases &= thisTestCase & CR & CR;
				}
			}

			// final replacement
			modelContent 		= replaceNoCase( modelContent, '|methods|', allMethods, 'all');
			modelTestContent 	= replaceNoCase( modelTestContent, '|TestCases|', allTestsCases, 'all');
		} else {
			modelContent = replaceNoCase( modelContent, '|methods|', '', 'all' );
		}

		// Write out the model
		var modelPath = '#directory#/#name#.cfc';
		// Create dir if it doesn't exist
		directorycreate( getDirectoryFromPath( modelPath ), true, true );
		file action='write' file='#modelPath#' mode ='777' output='#modelContent#';
		print.greenLine( 'Created #modelPath#' );

		if( arguments.tests ) {
			var testPath = '#arguments.TestsDirectory#/#arguments.name#Test.cfc';
			// Create dir if it doesn't exist
			directorycreate( getDirectoryFromPath( testPath ), true, true );
			// Create the tests
			file action='write' file='#testPath#' mode ='777' output='#modelTestContent#';
			// open file
			if( arguments.open ){ runCommand( "edit #testPath#" ); }			
			print.greenLine( 'Created #testPath#' );
		}

		// Open file?
		if( arguments.open ){ runCommand( "edit #modelPath#" ); }			
	}

}
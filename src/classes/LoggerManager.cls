/*
 *  Be aware of security implications of running foreign code in your package.
 *	@author Glen Watson
 *	@created 2014-02-21
 *	@see http://docs.oracle.com/javase/6/docs/api/java/util/logging/LogManager.html
 */
 public with sharing class LoggerManager {
	private static Map<String, Logger> loggers = new Map<String, Logger>();
	
	public static Logger getLogger(String name) {
		Logger logger = findLogger(name);
		if(logger == null) { //couldn't load logger, try default
			logger = getDefault();
		}
		if(logger == null) {
			throw new LoggerException('No logger configured for "'+name+'"! (And no "default" logger configured)');
		}
		return logger;
	}
	
	private static Logger getDefault() {
		return findLogger('default');
	}
	
	public static Logger findLogger(String name) {
		Logger logger = null;
		if(loggers.containsKey(name)) { //load from cache
			logger = loggers.get(name);
		} else { //no logger found, load it
			logger = loadLogger(name);
		}
		return logger;
	}
	
	/*
	 * Search for a logger in the config, load it from it's providers, add it to the cache
	 */
	private static Logger loadLogger(String name) {
		String[] providerNames = getProviderNamesForName(name);
		LoggerHandlerProvider__c[] providers = [SELECT Namespace__c, ClassName__c FROM LoggerHandlerProvider__c WHERE Name IN :providerNames];
		if(providers.size() > 0) {
			TypeDefinition[] defs = extractTypeDefs(providers);
			Logger logger = buildLoggerFromProviders(defs);
			if(logger != null) {
				loggers.put(name, logger);
				return logger;
			}
		}
		return null;
	}
	
	private static String[] getProviderNamesForName(String name) {
		LoggerConfig__c[] configProviderNames = [SELECT HandlerProviderName__c FROM LoggerConfig__c WHERE LoggerName__c = :name];
		String[] providerNames = new String[0];
		for(LoggerConfig__c configProviderName : configProviderNames) {
			providerNames.add(configProviderName.HandlerProviderName__c);
		}
		return providerNames;
	}
	
	private static TypeDefinition[] extractTypeDefs(LoggerHandlerProvider__c[] providers) {
		TypeDefinition[] defs = new TypeDefinition[0];
		for(LoggerHandlerProvider__c provider : providers) {
			defs.add(new TypeDefinition(provider.Namespace__c, provider.ClassName__c));
		}
		return defs;
	}
	
	private static Logger buildLoggerFromProviders(TypeDefinition[] handleProviderDefinitions) {
		Logger logger = new Logger();
		for(TypeDefinition handleProviderName : handleProviderDefinitions) {
			logger.addHandler(loadHandler(handleProviderName.namespace, handleProviderName.typeName));
		}
		return logger;
	}
	
	// Namespaces are required, see https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_methods_system_type.htm#apex_System_Type_forName_2
	private static Handler loadHandler(String namespace, String className) {
		Type t = Type.forName(namespace, className);
		if(t == null) {
			throw new LoggerException('"' + (namespace == null ? '' : namespace) + '" "' + classname + '" is not a valid type.');
		}
		Object obj = t.newInstance();
		if(!(obj instanceof HandlerProvider)) {
			throw new LoggerException(t.toString() + ' must implement LoggerManager.HandlerProvider');
		}
		HandlerProvider handlerProvider = (HandlerProvider) obj;
		return handlerProvider.getHandler();
	}
	
	/*
	 * Implementors of this interface must provide a no-arg contructor
	 */
	public interface HandlerProvider {
		Handler getHandler();
	}
	
	private class TypeDefinition {
		public String namespace;
		public String typeName;
		
		public TypeDefinition(String namespace, String typeName) {
			this.namespace = namespace;
			this.typeName = typeName;
		}
		
		public TypeDefinition(String typeName) {
			this('', typeName);
		}
	}
}
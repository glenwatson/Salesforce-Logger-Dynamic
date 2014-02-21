/*
 *	@author Glen Watson
 *	@created 2013-02-25
 *	@see http://docs.oracle.com/javase/6/docs/api/java/util/logging/Logger.html
 */
public class Logger {
	private static final System.LoggingLevel DEFAULT_LEVEL = System.LoggingLevel.DEBUG;
	private List<Handler> handlers = new List<Handler>();
	
	private Filter filter;
	
	public Logger() {}
	
	public void addHandler(Handler handler) {
		handlers.add(handler);
	}
	
	public void setFilter(Filter f) {
		filter = f;
	}
	public Filter getFilter() {
		return filter;
	}
	
	public void log(System.LoggingLevel lvl, String msg) {
		publish(new LogRecord(lvl, msg));
	}
	
	public void log(System.LoggingLevel lvl, String msg, Exception ex) {
		publish(new LogRecord(lvl, msg, ex));
	}
	
	public void log(String msg, Exception ex) {
		publish(new LogRecord(System.LoggingLevel.ERROR, msg, ex));
	}
	
	/* Convenience Methods */
	/* Method for each level */
	public void error(String msg) {
		log(System.LoggingLevel.ERROR, msg);
	}
	public void warn(String msg) {
		log(System.LoggingLevel.WARN, msg);
	}
	public void debug(String msg) {
		log(System.LoggingLevel.DEBUG, msg);
	}
	public void info(String msg) {
		log(System.LoggingLevel.INFO, msg);
	}
	public void fine(String msg) {
		log(System.LoggingLevel.FINE, msg);
	}
	public void finer(String msg) {
		log(System.LoggingLevel.FINER, msg);
	}
	public void finest(String msg) {
		log(System.LoggingLevel.FINEST, msg);
	}
	/*
		To replace System.debug()
	*/
	/* all single types */
	public void debug(System.LoggingLevel lvl, Object obj) {
		log(lvl, toString(obj));
	}
	public void debug(Object obj) {
		log(DEFAULT_LEVEL, toString(obj));
	}
	/* lists */
	public void debug(List<Object> objs) {
		log(DEFAULT_LEVEL, toString(objs));
	}
	public void debug(System.LoggingLevel lvl, List<Object> objs) {
		log(lvl, toString(objs));
	}
	/* sets */
	public void debug(Set<Object> objs) {
		log(DEFAULT_LEVEL, toString(objs));
	}
	public void debug(System.LoggingLevel lvl, Set<Object> objs) {
		log(lvl, toString(objs));
	}
	/* maps */
	public void debug(Map<Object, Object> objs) {
		log(DEFAULT_LEVEL, toString(objs));
	}
	public void debug(System.LoggingLevel lvl, Map<Object, Object> objs) {
		log(lvl, toString(objs));
	}
	
	private void publish(LogRecord record) {
		if(getFilter() == null || (getFilter() != null && getFilter().isLoggable(record))) {
			for(Handler handler : handlers) {
				handler.publish(record);
			}
		}
	}
	
	private static String toString(Object obj) {
		return String.valueOf(obj);
	}
	private static String toString(List<Object> objs) {
		return '{'+String.join(objs, ', ')+'}';
	}
	private static String toString(Set<Object> objs) {
		return '{'+String.join(new List<Object>(objs), ', ')+'}';
	}
	private static String toString(Map<Object, Object> objs) {
		return '{'+String.join(new List<Object>(objs.keySet()), ', ')+'}';
	}
}
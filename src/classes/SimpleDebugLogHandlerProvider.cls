/*
 *  An example handler provider implementation
 *  
 *	@author Glen Watson
 *	@created 2014-02-21
 *  
 */
public with sharing class SimpleDebugLogHandlerProvider implements LoggerManager.HandlerProvider {
	public Handler getHandler() {
		return new DebugLogHandler(new SimpleFormatter());
	}
}
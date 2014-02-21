Salesforce Logger (Dynamic)
=================
If you don't need to dynamically load your loggers, try [Salesforce Logger](https://github.com/glenwatson/Salesforce-Logger "Salesforce Logger") instead.


Useage
=================
Configure with the following:

Logger Handler Provider
-----------------

Record 1

- Name: "me - myHandler"
- Handler Provider Name: "myHandler"
- Logger Name: "me"

Record 2

- Name: "default - myHandler"
- Handler Provider Name: "myHandler"
- Logger Name: "default"

Logger Handler Provider
-----------------

Record 1

- Name: "myHandler"
- Namespace: "" (leave blank)	
- Class Name: "SimpleDebugLogHandlerProvider"

and use like so:
```
LoggerManager.getLogger('me').warn('test');
LoggerManager.getLogger('you').warn('test2');
```
The 'you' logger doesn't exist, so the default one is used.
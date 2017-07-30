// This file contains the source for the Javascript side of the
// WebViewJavascriptBridge. It is plaintext, but converted to an NSString
// via some preprocessor tricks.
//
// Previous implementations of WebViewJavascriptBridge loaded the javascript source
// from a resource. This worked fine for app developers, but library developers who
// included the bridge into their library, awkwardly had to ask consumers of their
// library to include the resource, violating their encapsulation. By including the
// Javascript as a string resource, the encapsulation of the library is maintained.

#import "WebViewJavascriptBridge_JS.h"

NSString * WebViewJavascriptBridge_js() {
	#define __wvjb_js_func__(x) #x
	
	// BEGIN preprocessorJSCode
	static NSString * preprocessorJSCode = @__wvjb_js_func__(
;(function() {
	if (window.WebViewJavascriptBridge) {
		return;
	}

	if (!window.onerror) {
		window.onerror = function(msg, url, line) {
			console.log("WebViewJavascriptBridge: ERROR:" + msg + "@" + url + ":" + line);
		}
	}
        
    // 初始化 WebViewJavascriptBridge 对象
	window.WebViewJavascriptBridge = {
		registerHandler: registerHandler,
		callHandler: callHandler,
		disableJavscriptAlertBoxSafetyTimeout: disableJavscriptAlertBoxSafetyTimeout,
		_fetchQueue: _fetchQueue,
		_handleMessageFromObjC: _handleMessageFromObjC
	};

	var messagingIframe;
	var sendMessageQueue = [];  // 保存已发送消息的队列
	var messageHandlers = {};   // 保存 handler 的对象
	
	var CUSTOM_PROTOCOL_SCHEME = 'https';
	var QUEUE_HAS_MESSAGE = '__wvjb_queue_message__';  // 发送消息的 URL scheme
	
	var responseCallbacks = {};  // 回调函数
	var uniqueId = 1;            // 保存 callback 的唯一标识
	var dispatchMessagesWithTimeoutSafety = true;

    // 注册 handler 的方法
	function registerHandler(handlerName, handler) {
		messageHandlers[handlerName] = handler;
	}
	
    // 调用 Native handler 的方法
	function callHandler(handlerName, data, responseCallback) {
        // 如果只有两个参数，并且第二个参数是 函数
		if (arguments.length == 2 && typeof data == 'function') {
			responseCallback = data;
			data = null;
		}
        
        // 发送消息给 Native
		_doSend({ handlerName:handlerName, data:data }, responseCallback);
	}
        
	function disableJavscriptAlertBoxSafetyTimeout() {
		dispatchMessagesWithTimeoutSafety = false;
	}
	
    // 发送消息给 Native
    // 一个消息包含一个 handler 和 data，以及一个 callbackId
    // 因为 JavaScript 中的 callback 是函数，不能直接传给 Objective-C，
	function _doSend(message, responseCallback) {
		
        if (responseCallback) {
			var callbackId = 'cb_'+(uniqueId++)+'_'+new Date().getTime();  // callbackId 的格式：cb + 唯一标识 id + 时间戳
            
			responseCallbacks[callbackId] = responseCallback;  // 保存 responseCallback 到 responseCallbacks 中去
            
			message['callbackId'] = callbackId;
		}
        
		sendMessageQueue.push(message); // 将要发送的消息保存到 sendMessageQueue 中
        
		messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;  // https://__wvjb_queue_message__
	}

    // 从消息队列中拉取消息
	function _fetchQueue() {
		var messageQueueString = JSON.stringify(sendMessageQueue);
    
		sendMessageQueue = [];
		return messageQueueString;
	}

    // 处理 Objective-C 中发来的消息
	function _dispatchMessageFromObjC(messageJSON) {
        
		if (dispatchMessagesWithTimeoutSafety) {
			setTimeout(_doDispatchMessageFromObjC);
		} else {
			 _doDispatchMessageFromObjC();
		}
		
        // 处理 Objective-C 中发来的消息
		function _doDispatchMessageFromObjC() {
            
			var message = JSON.parse(messageJSON);  // JSON 解析
			var messageHandler;
			var responseCallback;

			if (message.responseId) {  // 执行 JavaScript 调用原生时的回调
                
				responseCallback = responseCallbacks[message.responseId];
				if (!responseCallback) {
					return;
				}
				responseCallback(message.responseData);
				delete responseCallbacks[message.responseId];
                
			} else {  // 原生调用 JavaScript
                
				if (message.callbackId) {  // JavaScript 回调 Native 的 callback
                    
					var callbackResponseId = message.callbackId; // 取出原生传过来的 callbackId
					responseCallback = function(responseData) {
                        // 调用 _doSend 方法发送消息给 Native
						_doSend({ handlerName:message.handlerName, responseId:callbackResponseId, responseData:responseData });
					};
				}
				
				var handler = messageHandlers[message.handlerName]; // 根据 handlerName 取出 JavaScript 中的 handler
				if (!handler) {
					console.log("WebViewJavascriptBridge: WARNING: no handler for message from ObjC:", message);
				} else {
                    
					handler(message.data, responseCallback);  // 调用 JavaScript 中的 handler
				}
			}
		}
	}
	
    // 处理 Objective-C 中发来的消息
	function _handleMessageFromObjC(messageJSON) {
        _dispatchMessageFromObjC(messageJSON);
	}

    // 创建 iframe，用来加载 URL 发送消息给 Native
	messagingIframe = document.createElement('iframe');
	messagingIframe.style.display = 'none';
	messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;  // https://__wvjb_queue_message__
	document.documentElement.appendChild(messagingIframe);

	registerHandler("_disableJavascriptAlertBoxSafetyTimeout", disableJavscriptAlertBoxSafetyTimeout);
	
	setTimeout(_callWVJBCallbacks, 0);
	function _callWVJBCallbacks() {
		var callbacks = window.WVJBCallbacks;
		delete window.WVJBCallbacks;
		for (var i=0; i<callbacks.length; i++) {
			callbacks[i](WebViewJavascriptBridge);
		}
	}
})();
	); // END preprocessorJSCode

	#undef __wvjb_js_func__
	return preprocessorJSCode;
};

package mockolate.decorations.rpc
{
	import mockolate.decorations.Decorator;
	import mockolate.errors.MockolateError;
	import mockolate.ingredients.MockingCouverture;
	import mockolate.ingredients.Mockolate;
	import mockolate.ingredients.mockolate_ingredient;
	
	import mx.core.mx_internal;
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import org.hamcrest.Matcher;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperties;
	
	use namespace mockolate_ingredient;

	/**
	 * Decorates the MockingCouverture with expectations specific to HTTPService.
	 * 
	 * @see mockolate.ingredients.MockingCouverture#asHTTPService()
	 * 
	 * @example
	 * <listing version="3.0">
	 * 	  
	 * </listing>
	 * 
	 * @author drewbourne 
	 */
	public class HTTPServiceDecorator extends Decorator
	{
		private var _dataMatcher:Matcher;
		
		/**
		 * Constructor
		 */
		public function HTTPServiceDecorator(mockolate:Mockolate)
		{
			super(mockolate);	
			
			initialize();
		}
		
		/**
		 * @private 
		 */
		protected function initialize():void 
		{
			if (!(this.mockolate.target is HTTPService))
			{
				throw new MockolateError(["Mockolate instance is not a HTTPService", [this.mockolate.target]], this.mockolate, this.mockolate.target);
			}			
		}
		
		/**
		 * Specify the HTTP Method to expect the HTTPService to be set to.
		 * 
		 * Accepts either a HTTP Method as a String, or a Matcher against which
		 * the set method will be checked.
		 */
		public function method(httpMethodOrMatcher:Object):HTTPServiceDecorator
		{
			var httpMethodMatcher:Matcher
				= httpMethodOrMatcher is Matcher
				? httpMethodOrMatcher as Matcher
				: equalTo(httpMethodOrMatcher);
			
			mocker.setter("method").arg(httpMethodMatcher).once();
			
			return this;
		}
		
		/**
		 * Specify the HTTP Headers to expect the HTTPService to be set with.
		 * 
		 * Accepts either an Object of <code>header-name: header-value</code>,
		 * or a Matcher against which the set headers will be checked.
		 */
		public function headers(headersOrMatcher:Object):HTTPServiceDecorator
		{
			var headersMatcher:Matcher 
				= headersOrMatcher is Matcher
				? headersOrMatcher as Matcher
				: hasProperties(headersOrMatcher);
			
			mocker.setter("headers").arg(headersMatcher).once();
			
			return this;
		}
		
		/**
		 * Specify the expected data that the HTTPService send() method will be 
		 * called with.
		 * 
		 * Accepts either an Object of <code>parameter-name: paramter-value</code>,
		 * or a Matcher against which the sent data will be checked.
		 */
		public function send(dataOrMatcher:Object):HTTPServiceDecorator
		{
			_dataMatcher 
				= dataOrMatcher is Matcher
				? dataOrMatcher as Matcher
				: hasProperties(dataOrMatcher);
				
			return this;
		}
			
		/**
		 * Decorates the HTTPService to respond with a ResultEvent.
		 * 
		 * @example
		 * <listing version="3.0">
		 * </listing>
		 */
		public function result(resultData:Object):HTTPServiceDecorator
		{
			var token:AsyncToken = new AsyncToken();
			var resultEvent:ResultEvent = new ResultEvent(ResultEvent.RESULT, false, false, resultData, token);
			
			mocker
				.method("send")
				.args(_dataMatcher)
				.returns(token)
				.answers(new ResultAnswer(token, resultEvent))
				.dispatches(resultEvent);			
			
			return this;
		}
		
		/**
		 * Decorates the HTTPService to respond with a FaultEvent.
		 * 
		 * @example
		 * <listing version="3.0">
		 * </listing>
		 */
		public function fault(faultCode:String, faultString:String, faultDetail:String):HTTPServiceDecorator
		{
			var token:AsyncToken = new AsyncToken();
			var faultEvent:FaultEvent = new FaultEvent(FaultEvent.FAULT, false, false, new Fault(faultCode, faultString, faultDetail), token); 
			
			mocker
				.method("send")
				.args(_dataMatcher)
				.returns(token)
				.answers(new FaultAnswer(token, faultEvent))
				.dispatches(faultEvent);	
			
			return this;
		}
	}
}

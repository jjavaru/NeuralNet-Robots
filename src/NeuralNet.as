package
{
	import flash.utils.Dictionary;
	
	public class NeuralNet
	{
		public var inputs:int
		public var hidden:int
		public var outputs:int
		public var hiddenLayer:Boolean = true
		
		public var layer1:Array
		public var layer2:Array
		
		protected var dLayer1:Array
		protected var dLayer2:Array
		
		public var delta_hidden:Array
		public var delta_output:Array
		
		protected var learningRate:Number = .25
		protected var alpha:Number = .8
		
		protected var midArr:Array
		protected var cacheDict:Dictionary = new Dictionary()
		
		public var debug:Boolean = false
		
		public function NeuralNet(inp:int,hid:int,out:int,blank:Boolean=false)
		{
			this.inputs = inp
			this.hidden = hid
			this.outputs = out
			
			if(hidden == 0){
				hidden = outputs
				hiddenLayer = false
			}
			
			delta_hidden = new Array(hidden)
			delta_output = new Array(outputs)
			
			if(blank) return
				
			this.layer1 = new Array()
			this.dLayer1 = new Array()
			for(var i:Number = 0;i<inputs;i++){
				var t:Array = new Array()
				var d:Array = new Array()
				for(var j:Number = 0;j<hidden;j++){
					t.push(Math.random()-.5)
					d.push(0.0)
				}
				layer1.push(t)
				dLayer1.push(d)
			}
			
			if(hiddenLayer){
				this.layer2 = new Array()
				this.dLayer2 = new Array()
				for(var i2:Number = 0;i2<hidden;i2++){
					var t2:Array = new Array()
					var d2:Array = new Array()
					for(var j2:Number = 0;j2<outputs;j2++){
						t2.push(Math.random()-.5)
						d2.push(0.0)
					}
					layer2.push(t2)
					dLayer2.push(d2)
				}
			}
		}
		
		public function mate(net:NeuralNet):NeuralNet{
			var child:NeuralNet = new NeuralNet(inputs,hidden,outputs,true)
			var i:Number
			var j:Number
			var action:Number
			
			child.layer1 = new Array(inputs)
			child.dLayer1 = new Array(inputs)
			for(i = 0;i<inputs;i++){
				child.layer1[i] = new Array(hidden)
				child.dLayer1[i] = new Array(hidden)
				for(j = 0;j<hidden;j++){
					action = Math.random()
					if(action < .75){
						child.layer1[i][j] = this.layer1[i][j]
					} else if(action < .95){
						child.layer1[i][j] = net.layer1[i][j]
					} else if(action < .99){
						child.layer1[i][j] = (net.layer1[i][j] + this.layer1[i][j])/2
					} else {
						child.layer1[i][j] = Math.random()-.5
					}
					child.dLayer1[i][j] = 0.0
				}
			}
			
			if(!hiddenLayer) return child
			
			child.layer2 = new Array(hidden)
			child.dLayer2 = new Array(hidden)
			for(i = 0;i<hidden;i++){
				child.layer2[i] = new Array(outputs)
				child.dLayer2[i] = new Array(outputs)
				for(j = 0;j<outputs;j++){
					action = Math.random()
					if(action < .75){
						child.layer2[i][j] = this.layer2[i][j]
					} else if(action < .95){
						child.layer2[i][j] = net.layer2[i][j]
					} else if(action < .99){
						child.layer2[i][j] = (net.layer2[i][j] + this.layer2[i][j])/2
					} else {
						child.layer2[i][j] = Math.random()-.5
					}
					child.dLayer2[i][j] = 0.0
				}
			}
			
			return child
		}
		
		
		public function decide(arr:Array):Array{
			if(arr.length != inputs){
				trace("input of wrong length",arr.length,inputs)
				return null
			}
			
			//if(cacheDict[arr] != null) return cacheDict[arr]
			
			midArr = new Array();
			for(var h:int = 0; h<hidden; h++){
				var sum:Number = 0.0
				for(var i:int = 0; i<inputs; i++){
					sum += layer1[i][h]*arr[i]
				}
				midArr.push(sigmoid(sum))
			}
			
			if(debug) trace("midarr",midArr)
			if(!hiddenLayer) return midArr
			
			var outArr:Array = new Array();
			for(var j:int = 0; j<outputs; j++){
				var sum2:Number = 0.0
				for(var k:int = 0; k<hidden; k++){
					sum2 += layer2[k][j]*midArr[k]
				}
				outArr.push(sigmoid(sum2))
			}
			
			//cacheDict[arr] = outArr
			return outArr	
		}
		
		protected function sigmoid(v:Number):Number{
			var ret:Number = 1.0 / ( Math.pow(Math.E,-v) + 1.0)
			return ret
		}
		
		public function backProp(Target:Array, Input:Array) :Number{
			var Output:Array = this.decide(Input)
			return this.adjustWeights(Target,Output,midArr,Input)
		}
		
		protected function adjustWeights(Target :Array, Output :Array, MidArray :Array, Input :Array):Number{
			var NetError:Number = 0;
			var gain:Number = 1
			for (var i:int=0; i<outputs; i++) {
			    //Out = Net->OutputLayer->Output[i];
			    var Out:Number = Output[i]
			    //Err = Target[i-1]-Out;
			    var Err:Number = Target[i]-Out
			    //Net->OutputLayer->Error[i] = Net->Gain * Out * (1-Out) * Err;
			    delta_output[i] = gain * Out * (1-Out) * Err
			    //NetError += 0.5 * sqr(Err);
			    NetError += 0.5 * Err * Err
			}
			//trace("NetError",NetError)
			
			for (i=0; i<hidden; i++) {
				//Out = Lower->Output[i];
				Out = MidArray[i]
				Err = 0;
				for (var j:int=0; j<outputs; j++) {
					//Err += Upper->Weight[j][i] * Upper->Error[j];
					Err += layer2[i][j] * delta_output[j]
				}
				//Lower->Error[i] = Net->Gain * Out * (1-Out) * Err;
				delta_hidden[i] = gain * Out * (1-Out) * Err
			}
			
			for (i=0; i<outputs; i++) {
		    	for (j=0; j<hidden; j++) {
		        	//Out = Net->Layer[l-1]->Output[j];
		        	Out = MidArray[j]
		        	//Err = Net->Layer[l]->Error[i];
		        	Err = delta_output[i]
		        	//dWeight = Net->Layer[l]->dWeight[i][j];
		        	//Net->Layer[l]->Weight[i][j] += Net->Eta * Err * Out + Net->Alpha * dWeight;
		        	layer2[j][i] += learningRate * Err * Out + alpha * dLayer2[j][i]
		        	//Net->Layer[l]->dWeight[i][j] = Net->Eta * Err * Out;
		        	dLayer2[j][i] = learningRate * Err * Out;
		      	}
		    }
			
			for (i=0; i<hidden; i++) {
		    	for (j=0; j<inputs; j++) {
		        	Out = Input[j]
		        	Err = delta_hidden[i]
		        	layer1[j][i] += learningRate * Err * Out + alpha * dLayer1[j][i]
		        	dLayer1[j][i] = learningRate * Err * Out;
		      	}
		    }
		    
		    return NetError
		}
		
		
	}
	
	
}
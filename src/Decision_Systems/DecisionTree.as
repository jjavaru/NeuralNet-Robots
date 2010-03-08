package Decision_Systems
{
	public class DecisionTree
	{
		public static var variableNames:Array = []
		
		protected var left:DecisionTree:
		
		public function DecisionTree(inputs:int, outputs:int, initialHeight:int = 4)
		{
			
			generateRandom([1,2,3,4],initialHeight)
		}
		
		protected function generateRandom(inputs:Array,depth:int) :void{
			
			var input:int = inputs[Math.floor(Math.random()*inputs.length)]
			
		}

	}
}
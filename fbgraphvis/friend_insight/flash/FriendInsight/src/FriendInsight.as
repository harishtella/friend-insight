package 
{
	import com.adobe.serialization.json.JSON;
	import com.goodinson.snapshot.*;
	import com.pixelbreaker.ui.osx.MacMouseWheel;
	
	import flare.apps.App;
	import flare.controls.ClickControl;
	import flare.controls.PanZoomControl;
	import flare.controls.TooltipControl;
	import flare.display.DirtySprite;
	import flare.display.TextSprite;
	import flare.events.CheckBoxEvent;
	import flare.events.PanZoomEvent;
	import flare.events.SliderEvent;
	import flare.query.methods.div;
	import flare.query.methods.eq;
	import flare.query.methods.neq;
	import flare.vis.Visualization;
	import flare.vis.controls.HoverControl;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.Tree;
	import flare.vis.events.SelectionEvent;
	import flare.vis.operator.encoder.PropertyEncoder;
	import flare.vis.operator.label.RadialLabeler;
	import flare.vis.operator.layout.BundledEdgeRouter;
	import flare.vis.operator.layout.CircleLayout;
	import flare.widgets.ExitButton;
	import flare.widgets.ImageButton;
	import flare.widgets.ImageCheckBox;
	import flare.widgets.ImageSlider;
	import flare.widgets.Link;
	import flare.widgets.LinkGroup;
	import flare.widgets.ProgressBar;
	import flare.widgets.SearchBoxAdv;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.core.BitmapAsset;
			
	[SWF(backgroundColor="#ffffff", frameRate="30")]
	public class FriendInsight extends flare.apps.App
	{
		/** We will be rotating text, so we embed the font. */
		[Embed(source="verdana.TTF", fontName="Verdana")]
		private static var _font:Class;
		/** Icon for snap shot button */		
        [Embed(source="/assets/snapshot.png")]
        private static var SnapshotIcon:Class;
		/** Icon for information check box */
        [Embed(source="/assets/information.png")]
        private static var InformationIcon:Class;
		/** Icon for pan and zoom check box*/
        [Embed(source="/assets/pan_zoom.png")]
        private static var PanZoomIcon:Class;
		/** Icon for slider */
        [Embed(source="/assets/curve.png")]
        private static var curveIcon:Class;    
        [Embed(source="/assets/line.png")]
        private static var lineIcon:Class;    
		/** Icon for go back to app homepage */
        [Embed(source="/assets/home.png")]
        private static var homeIcon:Class;    
		/** Icon for search user names */
        [Embed(source="/assets/search.png")]
        private static var searchIcon:Class;    
                        
		private var _url:String;

		private var _data:Data;

		private var _vis:Visualization;
		private var _bundle:BundledEdgeRouter;
		private var _detail:TextSprite;
		private var _bar:ProgressBar;
		private var _bounds:Rectangle;
		private var _slider:ImageSlider;
		private var _zoomPanBox:ImageCheckBox;
		private var _helpBox:ImageCheckBox;
		private var _snapshotButton:ImageButton;
		private var _exitButton:ExitButton;
		private var _searchCheckBox:ImageCheckBox;
		private var _searchBox:SearchBoxAdv;
							
		private var _tooltip:TooltipControl = null;
		private var _networkClick:ClickControl;		
		private var _hovNodeDetail:HoverControl;
		private var _panZoom:PanZoomControl;
		private var _friendClicked:Boolean = false;
		private var _friendSearched:Boolean = false;
		
		private var _focus:NodeSprite;		
		private var _links:LinkGroup;
		private var _curLink:int;
		
		//variables for progressive rendering
		private var _progDrawTimer:Timer;
		private var _progDrawToDoCount:Number;
		//frequency of progressive drawing timer
		private var _progDrawFreq:Number = 50;
		
		private var _progDrawEdgeBuckets:Dictionary;
		private var _progDrawKeys:Array;
		protected override function init():void
		{
			var filename:String =  Object(root).loaderInfo.parameters.filename;
			this._url = "http://friendinsight.web.cs.illinois.edu/friend_insight/output_json/" + filename + ".json";
			
			// create progress bar
			addChild(_bar = new ProgressBar());
			_bar.bar.filters = [new DropShadowFilter(1)];
						
			// load data file
			var ldr:URLLoader = new URLLoader(new URLRequest(_url));
			_bar.loadURL(ldr, function():void {
				var obj:Array = JSON.decode(ldr.data as String) as Array;
				_data = buildData(obj);
				visualize(_data);                
				_bar = null;
															
			});
		}
		private function visualize(data:Data):void
		{			
			// configure data nodes and edges
			data.nodes.setProperties({
				shape: null,                  // no shape, use labels instead
				visible: eq("childDegree",0), // only show leaf nodes
				buttonMode: true              // show hand cursor
			});
			data.edges.setProperties({
				lineWidth: 2,
				lineColor: 0xff0055cc,
				mouseEnabled: false,          // non-interactive edges
				visible: neq("source.parentNode","target.parentNode")
			});

			// configure tree nodes and edges
			data.tree.nodes.setProperties({
				shape: null,//Shapes.WEDGE,   // no shape, use labels instead
				visible: true, 				  // only show leaf nodes
				buttonMode: true              // show hand cursor
			});									
			data.tree.edges.setProperties({
				lineWidth: 1,
				lineColor: 0xffcccccc,
				mouseEnabled: false,          // non-interactive edges
				visible: true
			});
			
			// define the visualization
			_vis = new Visualization(data);
			
			// place around circle by tree structure, radius mapped to depth
			// make a large inner radius so labels are closer to circumference			
			_vis.operators.add(new CircleLayout("depth", null, true));
			CircleLayout(_vis.operators.last).startRadiusFraction = 2.5/5;
			
			// bundle edges to route along the tree structure
			_bundle = new BundledEdgeRouter(0.95);
			_vis.operators.add(_bundle);
			// set the edge alpha values
			// longer edge, lighter alpha: 1/(2*numCtrlPoints)
			_vis.operators.add(new PropertyEncoder(
				{alpha: div(1,"points.length")}, Data.EDGES));
						
			// add labels	
			_vis.operators.add(new RadialLabeler(
				formatName, true, new TextFormat("Verdana", 7), eq("childDegree",0))); // leaf nodes only			
			_vis.operators.last.textMode = TextSprite.EMBED; // embed fonts!
						
			_vis.update();
			
			var visbox:Sprite = new Sprite();
			visbox.addChild(_vis);
			addChild(visbox);
					 			
			// highlight friends of a friend on single-click
			_vis.controls.add(_networkClick = new ClickControl(NodeSprite, 1,
				function(evt:SelectionEvent):void {
					if (_focus && _focus != evt.node) {
						unhighlight(_focus);
					}
					_focus = evt.node;
					highlight(evt);
				
					showAllDeps(evt, NodeSprite.GRAPH_LINKS);
					_friendClicked = true;
				},
				// show all edges and nodes as normal
				function(evt:SelectionEvent):void {
					if (_focus) unhighlight(_focus);
					_focus = null;
					_vis.data.edges["visible"] = 
						neq("source.parentNode","target.parentNode");
					_vis.data.nodes["alpha"] = 1;
					_friendClicked = false;
				}
			));
			
			// mouse-over details
			_vis.controls.add(_hovNodeDetail = new HoverControl(NodeSprite,
				HoverControl.DONT_MOVE,
				function(evt:SelectionEvent):void {					
					_detail.text = formatName(evt.node);
				},
				function(evt:SelectionEvent):void {
					//Just say Friend Insight when no friend is selected.
					_detail.text = "Friend Insight";
				}
			));			

 			// create pan zoom control
 			//_vis.controls.add();
 			_panZoom = new PanZoomControl()
 			_panZoom.hitArea = _vis;
 			_panZoom.addEventListener(PanZoomEvent.PZACTIVE, edgesControl);
			_panZoom.addEventListener(PanZoomEvent.PZOFF, edgesControl);

			// add the detail pane
			addDetail();

			// compute the layout
			if (_bounds) resize(_bounds);
		}	
		
		/** custom label function removes package names
		 add deals names with any number of initials **/
		private function formatName(d:DataSprite):String 
		{
			var name:String = d.data.name;
			return name.substring(name.lastIndexOf("@")+1);
		}
		
		/** Add highlight to a node and connected edges/nodes */
		private function highlight(n:*):void
		{
			var node:NodeSprite = n is NodeSprite ?
				NodeSprite(n) : SelectionEvent(n).node;
				
			// highlight mouse-over node
			node.props.label.color = 0x00ee00;
			node.props.label.bold = true;
			// highlight links for friends that depend on the focus
			node.visitEdges(function(e:EdgeSprite):void {
				e.alpha = 0.5;
				e.lineColor = 0xffff0000;				
				_vis.marks.setChildIndex(e, _vis.marks.numChildren-1);
				if(e.source != node){
					e.source.props.label.color = 0xC82B25;
				} else if (e.target != node) {
					e.target.props.label.color = 0xC82B25; 
				}
			}, NodeSprite.GRAPH_LINKS);
		}
		
		/** Remove highlight from a node and connected edges/nodes */
		private function unhighlight(n:*):void
		{
			var node:NodeSprite = n is NodeSprite ?
				NodeSprite(n) : SelectionEvent(n).node;
			// set everything back to normal
			node.props.label.color = 0;
			node.props.label.bold = false;
			node.setEdgeProperties({
				alpha: div(1, "points.length"),
				lineColor: 0xff0055cc,
				"source.props.label.color": 0,
				"target.props.label.color": 0
			}, NodeSprite.GRAPH_LINKS);
		}
		
		/** Traverse all dependencies for a given class */
		private function showAllDeps(n:*, linkType:int):void
		{	
			var node:NodeSprite = n is NodeSprite ?
				NodeSprite(n) : SelectionEvent(n).node;
			
			// first, find all the distance one friends
			var q:Array = new Array();
			q[0] = node;
			
			var map:Dictionary = new Dictionary();
			while (q.length > 0) {
				var u:NodeSprite = q.shift();
				map[u] = true;
				u.visitNodes(function(v:NodeSprite):void {					
					map[v] = true;
				}, linkType);
			}
			// now highlight nodes and edges
			_vis.data.edges.visit(function(e:EdgeSprite):void {
				e.visible = map[e.source] && map[e.target];
			});
			_vis.data.nodes.visit(function(n:NodeSprite):void {
				n.alpha = map[n] ? 1 : 0.4;
			});
		}
		
		/** Add other details to the UI */
		private function addDetail():void
		{	
			// the link group that switches between network or hierarchy			
			addChild(_links = new LinkGroup());
			var link1:Link = new Link("Network", 14);
			link1.addEventListener(MouseEvent.CLICK, showNetwork);
			_links.add(link1);
			var link2:Link = new Link("Hierarchy", 14);
			link2.addEventListener(MouseEvent.CLICK, showHierarchy);
			_links.add(link2);
			_links.select(link1);
			_curLink = 0;				
			
			//mac mouse wheel fix
			MacMouseWheel.setup( stage ); 
			
			var filter:DropShadowFilter = new DropShadowFilter(1);
			
			var home_logo:BitmapAsset = BitmapAsset(new homeIcon());
			home_logo.filters = [filter];			
			addChild(_exitButton = new ExitButton(home_logo, "http://apps.facebook.com/friendinsight/"));
			
			_searchBox = new SearchBoxAdv(new TextFormat("Verdana", 11), 100);
			_searchBox.addEventListener(SearchBoxAdv.SEARCH, searchName);

			var search_log:BitmapAsset = BitmapAsset(new searchIcon());
			search_log.filters = [filter];
			addChild(_searchCheckBox = new ImageCheckBox(search_log));
			_searchCheckBox.addEventListener(CheckBoxEvent.CHANGE, switchSearch);
			_searchCheckBox.checked = true;
						
			//add snapshot button
			var snapshot_logo:BitmapAsset = BitmapAsset(new SnapshotIcon());
			snapshot_logo.filters = [filter];
			addChild(_snapshotButton = new ImageButton(snapshot_logo));
			_snapshotButton.addEventListener(MouseEvent.CLICK, takeSnapShot);
						
			// create slider bar
			var curve_log:BitmapAsset = BitmapAsset(new curveIcon());			
			var line_log:BitmapAsset = BitmapAsset(new lineIcon());			
			addChild(_slider = new ImageSlider(line_log, curve_log));
			_slider.percent = _bundle.bundling;
			_slider.addEventListener(SliderEvent.CHANGE, changeBundleStrength);
			_slider.filters = [filter];
							
			var panZoom_log:BitmapAsset = BitmapAsset(new PanZoomIcon());
			panZoom_log.filters = [filter];
			addChild(_zoomPanBox = new ImageCheckBox(panZoom_log));
			_zoomPanBox.addEventListener(CheckBoxEvent.CHANGE, switchZoomAHover);
			_zoomPanBox.checked = true;				
							
			addChild(_detail = new TextSprite("", new TextFormat("Times New Roman",18,null,true,true)));
			_detail.text = "Friend Insight";			

			//addChild(_helpBox = new CheckBox("Help"));				
			var info_log:BitmapAsset = BitmapAsset(new InformationIcon());
			info_log.filters = [filter];
			addChild(_helpBox = new ImageCheckBox(info_log));
			_helpBox.addEventListener(CheckBoxEvent.CHANGE, switchHelp);
			_helpBox.checked = true;										
		}
		
		/** Event handler for the slider */
		protected function changeBundleStrength(evt:SliderEvent):void 
		{
			_bundle.bundling = evt.percent;			
			_vis.update(_bundle);
		}
	
		protected function switchSearch(evt:CheckBoxEvent):void
		{
			if (evt.checked) { 
				addChild(_searchBox);
			} else {
				removeChild(_searchBox);
				_friendSearched = false;
				if (isNetworkShown() && !_friendClicked) {					
					_vis.data.edges["visible"] = 
						neq("source.parentNode","target.parentNode");
					_vis.data.nodes["alpha"] = 1;
				}
			}
		}

		/** Event handler for the checkbox */
		protected function switchZoomAHover(evt:CheckBoxEvent):void 
		{
			if (evt.checked) {
				_vis.controls.add(_panZoom);
			} else {
				_vis.controls.remove(_panZoom);						
			}
		}
		
		/** take a snap shot for users so that it can be published on their profiles */
		protected function saveSnapShotOnServer():void
		{
			// switch off the labels
			_vis.data.nodes.setProperty("props.label.visible",					
			false, null, eq("childDegree",0));

			var snapshot:Snapshot = new Snapshot() 
			snapshot.snap(_vis, "save");
			snapshot.send("http://friendinsight.web.cs.illinois.edu/alpha/php/snapshot.php");

			// switch on the labels
			_vis.data.nodes.setProperty("props.label.visible",					
			true, null, eq("childDegree",0));						
		}
		
		protected function takeSnapShot(evt:MouseEvent):void
		{
			var snapshot:Snapshot = new Snapshot() 
			snapshot.snap(_vis, "prompt");
			snapshot.saveToLocal();
		}
		
		protected function edgesControl(evt:PanZoomEvent):void
		{
			if (isNetworkShown() && !_friendClicked && !_friendSearched) {
				if (evt.type == PanZoomEvent.PZACTIVE){
					if (_progDrawTimer != null) {
						//stop current progressive rendering
						_progDrawTimer.stop();
					}
					_vis.data.edges["visible"] = false;
					//trace("on" + DirtySprite.dirtyListSize());
				} else if (evt.type == PanZoomEvent.PZOFF) {
					//previous we would simply set visible on all the edges that should be shown in one shot 
					_vis.data.edges["visible"] = neq("source.parentNode",
											"target.parentNode");
				}
			}
		}
		
		protected function progDrawComputeEdgeBuckets():void
		{
			_progDrawEdgeBuckets = new Dictionary();
			for (var curI:uint = 0; curI < _vis.data.edges.length; curI++){
					var e:EdgeSprite = (_vis.data.edges[curI] as EdgeSprite);
					var edgeLength:Number = 0;
					
					var u:NodeSprite = e.source;
					var v:NodeSprite = e.target;
					var d1:Number = u.depth;
					var d2:Number = v.depth;
					while (d1 > d2) { u=u.parentNode; --d1; edgeLength++; }
					while (d2 > d1) { v=v.parentNode; --d2; edgeLength++; }
					while (u != v) {
						u=u.parentNode; --d1; edgeLength++;
						v=v.parentNode; --d2; edgeLength++;
					}
					
					if (_progDrawEdgeBuckets[edgeLength] == null){
						//trace("null key" + curI);
						_progDrawEdgeBuckets[edgeLength] = [];
						(_progDrawEdgeBuckets[edgeLength] as Array).push(curI);
					} else {
						(_progDrawEdgeBuckets[edgeLength] as Array).push(curI);
					}
			}
		}
		
		protected function progDrawHandler(e:TimerEvent):void{
			//trace("progDrawHandler fired.");
			//trace("progDrawToDoCount: " + _progDrawToDoCount);
			
			var edgesPerEvent:uint = 10;
			var edgesLeftThisEvent:uint = edgesPerEvent;
			
			//no keys left means we are done rendering
			if (_progDrawKeys.length == 0){
				e.target.stop();
				return;
			}
			var curBucket:uint = _progDrawKeys[_progDrawKeys.length - 1];
			
			
			while (edgesLeftThisEvent > 0) {
				//move onto the next bucket if current one is empty
				if ((_progDrawEdgeBuckets[curBucket] as Array).length == 0){
					_progDrawKeys.pop();
					//no keys left means we are done rendering
					if (_progDrawKeys.length == 0){
						e.target.stop();
						return;
					}
					curBucket = _progDrawKeys[_progDrawKeys.length - 1];
				}
				
				var curIndex:uint = (_progDrawEdgeBuckets[curBucket] as Array).pop();
				(this._vis.data.edges[curIndex] as DataSprite).visible = true;	
				edgesLeftThisEvent--;		
			}
		}
				
		/** Event handler for the help box */
		protected function switchHelp(evt:CheckBoxEvent):void
		{
			if (evt.checked) {
				if (_tooltip == null) {
					_tooltip = new TooltipControl();
					_tooltip.addTooltip(_helpBox, "Mouse over everywhere to see " + 
													"<br>available help information, " + 
													"<br>click again to disable");
					_tooltip.addTooltip(_zoomPanBox, "Pan by clicking and dragging graph. " + 
													"<br>Zoom by holding mouse button and shift " + 
													"<br>and moving mouse up/down");
					_tooltip.addTooltip(_links.getChildAt(0), "Network mode, click a friend to view other friends " + 
																"<br>you have in common");
					_tooltip.addTooltip(_links.getChildAt(1), "Hierarchy mode, see who is close to who in your friends");
					_tooltip.addTooltip(_slider, "Drag to change the curveness of the curves");
					_tooltip.addTooltip(_searchCheckBox, "Click to enable name search, " + 
														"<br>click again to disable");
					_tooltip.addTooltip(_snapshotButton, "Click to take a snapshot and " + 
														"<br>save it to an image");
					_tooltip.addTooltip(_exitButton, "Click to exit the application and " + 
														"<br>return to the app page");
				}
				_tooltip.attach(this);
			} else {
				_tooltip.detach();
			}
		} 		
		
		/** resize the application */
		public override function resize(bounds:Rectangle):void
		{
			_bounds = bounds;
			if (_bar) {
				_bar.x = _bounds.width/2 - _bar.width/2;
				_bar.y = _bounds.height/2 - _bar.height/2;
			}
			if (_vis) {
				// automatically size labels based on bounds
				var d:Number = Math.min(_bounds.width, _bounds.height);
				var nnodes:int = _vis.data.nodes.length;
				var fontsz:int = 9;
				if (nnodes<40) { fontsz = 14; }
				if (nnodes<60) { fontsz = 13; } 
				else if (nnodes<100) { fontsz = 11; } 
				else if (nnodes<180) { fontsz = 9; }
				else if (nnodes<250) { fontsz = 7; }
				else if (nnodes<350) { fontsz = 5; }
				else if (nnodes<420) { fontsz = 4; }
				else { fontsz = 3; }
				 
				if (d<400) { fontsz *= 0.4; } 
				else if (d<470) { fontsz *= 0.55; } 
				else if (d<550) { fontsz *= 0.7; } 
				else if (d<650) { fontsz *= 0.8; } 
				else if (d<720) { fontsz *= 0.9; } 
				else if (d>900) { fontsz *= 1.1; }
												
				_vis.data.nodes.setProperty("props.label.size",					
					fontsz, null, eq("childDegree",0));
							
				// compute the visualization bounds				
				_vis.height = _bounds.height - 110 - fontsz*fontsz/2;
				_vis.width = _bounds.width;
				var sx:Number = _vis.transform.matrix.a;
				var sy:Number = _vis.transform.matrix.d;
				if(sx>sy) { _vis.width *= sy/sx; } 
				else { _vis.height *= sx/sy; }
				_vis.x = (_bounds.width - _vis.width)/2;
				_vis.y = _bounds.y + fontsz*fontsz/2;							

				// update				
				_vis.update();
															
				_detail.x = _bounds.width/2 - 60;				
				_detail.y = _bounds.height - 110;

				_links.x = (_bounds.width - _links.width)/2;
				_links.y = _bounds.height - 65;							 							
				
				var space:Number = 15;
				_slider.x = _bounds.width/2 - _slider.width/2;
				_zoomPanBox.x = _slider.x - _zoomPanBox.width - space;				
				_searchCheckBox.x = _zoomPanBox.x - _searchCheckBox.width - space;
				_searchBox.x = _searchCheckBox.x;   
				_helpBox.x = _slider.x + _slider.width + space;
				_snapshotButton.x = _helpBox.x + _helpBox.width + space;
				_exitButton.x = _snapshotButton.x + _snapshotButton.width + space; 
				
				_searchCheckBox.y = _helpBox.y = _zoomPanBox.y = 
				_snapshotButton.y = _exitButton.y = _bounds.height - 40;
				_slider.y = _bounds.height - 34;
				_searchBox.y = _searchCheckBox.y - _searchBox.height - 5;
																			
				// forcibly render to eliminate partial update bug, as
				// the standard RENDER event routing can get delayed.
				// remove this line for faster but unsynchronized resizes
				DirtySprite.renderDirty();
			}
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates the visualized data.
		 */
		public static function buildData(tuples:Array):Data
		{
			var data:Data = new Data();
			var tree:Tree = new Tree();
			var map:Object = {};
			
			tree.root = data.addNode({name:"flare", size:0});
			map.flare = tree.root;
			
			var t:Object, u:NodeSprite, v:NodeSprite;
			var path:Array, p:String, pp:String, i:uint;
			
			// build data set and tree edges
			tuples.sortOn("name");
			for each (t in tuples) {
				path = String(t.name).split("@");
				for (i=0, p=""; i<path.length-1; ++i) {
					pp = p;
					p += (i?"@":"") + path[i];
					if (!map[p]) {
						u = data.addNode({name:p, size:0});
						tree.addChild(map[pp], u);
						map[p] = u;
					}
				}
				t["package"] = p;
				u = data.addNode(t);
				tree.addChild(map[p], u);
				map[t.name] = u;
			}
			
			// create graph links
			for each (t in tuples) {
				u = map[t.name];
				for each (var name:String in t.imports) {
					v = map[name];
					if (v) data.addEdgeFor(u, v);
					else trace ("Missing node: "+name);
				}
			}
			
			// sort the list of children alphabetically by name
			for each (u in tree.nodes) {
				u.sortEdgesBy(NodeSprite.CHILD_LINKS, "target.data.name");
			}
			
			data.tree = tree;
			return data;
		}
		
		//debugging 
		//prints out DisplayList hierarchy, only prints container objects  
		private function traceDisplayList(container:DisplayObjectContainer, indentString:String = ""):void
		{
   			var child:DisplayObject;
			for (var i:uint=0; i < container.numChildren; i++) {
   				child = container.getChildAt(i);    		
    			if (container.getChildAt(i) is DisplayObjectContainer) {
        			trace(indentString, child, child.name); 
        			traceDisplayList(DisplayObjectContainer(child), indentString + "    ")
    			}
			}
    	}

		/** Show the network */
		protected function showNetwork(event:MouseEvent):void
		{
			var tgt:DisplayObject = event.target as DisplayObject;
			var idx:int = _links.getChildIndex(tgt);
			if (_curLink == idx) {
				return;
			}
			_curLink = idx;
						
			// update ui
			_slider.enabled = true;
			_searchCheckBox.enabled = true;
						
			if (_vis) {
				_vis.data = _data;				
				_vis.controls.add(_networkClick);
			}
		}	

		/** Show the hierarchy */	
		protected function showHierarchy(event:MouseEvent):void
		{
			var tgt:DisplayObject = event.target as DisplayObject;
			var idx:int = _links.getChildIndex(tgt);
			if (_curLink == idx) {
				return;
			}						
			_curLink = idx;
								
			// update ui	
			_slider.enabled = false;
			_searchCheckBox.checked = false;
			_searchCheckBox.enabled = false;
						
			if (_vis) {
				_vis.controls.remove(_networkClick);
				_vis.data = _data.tree;
			}
		}
				
		/** search node names */
		protected function searchName(event:Event):void
		{
			if (isNetworkShown()) {
				if(_friendClicked) {
					if (_focus) unhighlight(_focus);
					_focus = null;
					_friendClicked = false;					
				}
				_vis.data.edges["visible"] = 
						neq("source.parentNode","target.parentNode");
				_vis.data.nodes["alpha"] = 1;
	
				_friendSearched = false;
				var tosearch:String = _searchBox.text.toLocaleLowerCase();			
				var map:Dictionary = new Dictionary();
				_vis.data.nodes.visit(function(n:NodeSprite):void {
					var name:String = n.data.name.toLocaleLowerCase();
					var index:int =name.indexOf(tosearch); 
					map[n] = (index==-1) ? false : true;
					_friendSearched = _friendSearched || map[n]; 
					n.alpha = (index==-1) ? 0.4 : 1;
				});
				_vis.data.edges.visit(function(e:EdgeSprite):void {
					e.visible = map[e.source] || map[e.target];
				});
			}
		}
		
		/** Is network shown at this moment? */
		protected function isNetworkShown():Boolean
		{
			return _curLink == 0;
		}
	} // end of class FriendInsight
}

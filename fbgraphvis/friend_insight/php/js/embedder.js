var flashvars = {};
var params = {};
var attributes = {id:'friendinsight', name:'friendinsight'};
flashvars.filename = filename;
swfobject.embedSWF("FriendInsight.swf", "flashcontent", "99%", "99%", "10", "expressInstall.swf", flashvars, params, attributes);
swfmacmousewheel.registerObject(attributes.id);

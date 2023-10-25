mergeInto(LibraryManager.library, {
	StartJS: function() {
		console.log('start js')
	},

  GetCurrentPlayerName: function () {
    //window.alert("Hello, world!");
		return "YOI MEN";
  },

  HelloString: function (str) {
    window.alert(Pointer_stringify(str));
  },

  PrintFloatArray: function (array, size) {
    for(var i = 0; i < size; i++)
    console.log(HEAPF32[(array >> 2) + i]);
  },

  AddNumbers: function (x, y) {
    return x + y;
  },

  StringReturnValueFunction: function () {
    var returnStr = "bla";
    var bufferSize = lengthBytesUTF8(returnStr) + 1;
    var buffer = _malloc(bufferSize);
    stringToUTF8(returnStr, buffer, bufferSize);
    return buffer;
  },

  BindWebGLTexture: function (texture) {
    GLctx.bindTexture(GLctx.TEXTURE_2D, GL.textures[texture]);
  },

  BridgeGetPos: function (playerId, x, y) {
    if(window.lastX !== x || window.lastY !== y) {
      console.log('walkAbsolute', x, y)
      window.ff.game.position.walkAbsolute(x, y)
    }

    window.lastX = x
    window.lastY = y
  }

});

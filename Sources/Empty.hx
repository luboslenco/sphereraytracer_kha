package;

import kha.Framebuffer;
import kha.Image;
import kha.System;
import kha.Scheduler;
import kha.graphics4.Graphics;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;
import kha.graphics4.Usage;
import kha.graphics4.ConstantLocation;

class Empty {

	var pipe:PipelineState;
	var screenAlignedVB:VertexBuffer = null;
	var screenAlignedIB:IndexBuffer = null;
	
	var globalTime:Float = 0;
	var lastTime:Float;

	public function new() {

		var structure = new VertexStructure();
        structure.add("pos", VertexData.Float2);
        var structureLength = 2;

		var data = [-1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, 1.0];
		var indices = [0, 1, 2, 0, 2, 3];

		screenAlignedVB = new VertexBuffer(Std.int(data.length / structureLength),
										   structure, Usage.StaticUsage);
		
		var vertices = screenAlignedVB.lock();
		for (i in 0...vertices.length) {
			vertices.set(i, data[i]);
		}
		screenAlignedVB.unlock();

		screenAlignedIB = new IndexBuffer(indices.length, Usage.StaticUsage);
		var id = screenAlignedIB.lock();
		for (i in 0...id.length) {
			id[i] = indices[i];
		}
		screenAlignedIB.unlock();

		pipe = new PipelineState();
		pipe.inputLayout = [structure];
		pipe.fragmentShader = kha.Shaders.image_frag;
		pipe.vertexShader = kha.Shaders.quad_vert;
		pipe.compile();

		lastTime = Scheduler.time();
	}
	
	public function render(framebuffer:Framebuffer) {
		var g = framebuffer.g4;
		g.begin();

		g.setPipeline(pipe);
		setConstants(g, pipe);

		g.setVertexBuffer(screenAlignedVB);
		g.setIndexBuffer(screenAlignedIB);
		g.drawIndexedVertices();

		g.end();

		// Update
		globalTime += Scheduler.time() - lastTime;
  		lastTime = Scheduler.time();
	}

	function setConstants(g:Graphics, p:PipelineState) {
		// Just for simplicity, no need to get locations every frame
		g.setFloat(p.getConstantLocation("iGlobalTime"), globalTime);
		g.setFloat3(p.getConstantLocation("iResolution"), System.pixelWidth, System.pixelHeight, 0);
	}
}

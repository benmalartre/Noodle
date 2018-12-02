DeclareModule Perlin
  
	Global DoRepeat.i
	
	
	DataSection
	  ; Hash lookup table As defined by Ken Perlin.  This is a randomly
	  ; arranged Array of all numbers from 0-255 inclusive.
	  permutation_table:
	  Data.i  151,160,137,91,90,15					
		Data.i 131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23
		Data.i 190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33
		Data.i 88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166
		Data.i 77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244
		Data.i 102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196
		Data.i 135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123
		Data.i 5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42
		Data.i 223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9
		Data.i 129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228
		Data.i 251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107
		Data.i 49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254
		Data.i 138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
	EndDataSection
	
	#PERMUTATION_SIZE = 512
	Global Dim PERMUTATION.i(#PERMUTATION_SIZE); 													// Doubled permutation to avoid overflow
	
	Macro Unsigned(value)
    ((value) + 1) / 2
  EndMacro
  
	Declare Init()
	Declare.d OctavePerlin(x.d,y.d, z.d, octaves.i, persistence.d) 
	
	
	
EndDeclareModule

Module Perlin
  
  Procedure inc(num.i) 
	  
		num+1
		If (DoRepeat > 0) :  num = num%DoRepeat : EndIf
		
		ProcedureReturn num;
	EndProcedure
	
	
	Procedure.d grad(hash.i ,x.d,y.d,z.d)
	  ; Take the hashed value And take the first 4 bits of it (15 == 0b1111)
	  h.i = hash & 15			    
	  ; If the most significant bit (MSB) of the hash is 0 then set u = x.  Otherwise y.
	  If h < 8  
	    u.d = x 
	  Else
	    u.d = y
	  EndIf
	  
		
		; In Ken Perlin's original implementation this was another conditional operator (?:).  I expanded it For readability.
		v.d
		
		; If the first And second significant bits are 0 set v = y;/* %0100 */)	;	
		If(h < 4 )						    
		  v = y
		; If the first And second significant bits are 1 set v = x /* 0b1100 */ /* 0b1110*/
		ElseIf h = 12 Or h = 14 
		  v = x
		;If the first And second significant bits are Not equal (0/1, 1/0) set v = z
		Else 												
			v = z
			
			If (h&1): u=-u : EndIf
			If (h&2): v=-v : EndIf
		EndIf
		
		ProcedureReturn u+v; // Use the last 2 bits to decide if u and v are positive or negative.  Then return their addition.
	EndProcedure
	
	Macro fade(_t) 
		; Fade function As defined by Ken Perlin.  This eases coordinate values
		; so that they will "ease" towards integral values.  This ends up smoothing
		; the final output.
		((_t) * (_t) * (_t) * ((_t) * ((_t) * 6 - 15) + 10));			// 6t^5 - 15t^4 + 10t^3
	EndMacro
	
	Macro lerp(_a,_b,_x)
		((_a) + (_x) * ((_b) - (_a)))
	EndMacro
	
	Procedure.d perlin(x.d,y.d,z.d) 
	  ; If we have any Repeat on, change the coordinates To their "local" repetitions
		If DoRepeat > 0								
			x = Mod(x,DoRepeat);
			y = Mod(y,DoRepeat);
			z = Mod(z,DoRepeat);
		EndIf
		
		xi.i = Int(x) & 255;								// Calculate the "unit cube" that the point asked will be located in
		yi.i = Int(y) & 255;								// The left bound is ( |_x_|,|_y_|,|_z_| ) and the right bound is that
		zi.i = Int(z) & 255;								// plus 1.  Next we calculate the location (from 0.0 to 1.0) in that cube.
		xf.d = x-Int(x);								// We also fade the location to smooth the result.
		yf.d = y-Int(y);i
		zf.d = z-Int(z);
		u.d = fade(xf);
		v.d = fade(yf);
		w.d = fade(zf);
															
		Define.i aaa, aba, aab, abb, baa, bba, bab, bbb;
		aaa = PERMUTATION(PERMUTATION(PERMUTATION(    xi )+    yi )+    zi );
    aba = PERMUTATION(PERMUTATION(PERMUTATION(    xi )+inc(yi))+    zi );
    aab = PERMUTATION(PERMUTATION(PERMUTATION(    xi )+    yi )+inc(zi));
    abb = PERMUTATION(PERMUTATION(PERMUTATION(    xi )+inc(yi))+inc(zi));
    baa = PERMUTATION(PERMUTATION(PERMUTATION(inc(xi))+    yi )+    zi );
    bba = PERMUTATION(PERMUTATION(PERMUTATION(inc(xi))+inc(yi))+    zi );
    bab = PERMUTATION(PERMUTATION(PERMUTATION(inc(xi))+    yi )+inc(zi));
    bbb = PERMUTATION(PERMUTATION(PERMUTATION(inc(xi))+inc(yi))+inc(zi));
    
    
    ; The gradient function calculates the dot product between a pseudorandom
    ;// gradient vector And the vector from the input coordinate To the 8
    ;// surrounding points in its unit cube.
    ;// This is all then lerped together As a sort of weighted average based on the faded (u,v,w)
    ;// values we made earlier.
    
		Define.d x1, x2, y1, y2;
		x1 = lerp(	grad (aaa, xf  , yf  , zf),grad (baa, xf-1, yf  , zf),u);										
		x2 = lerp(	grad (aba, xf  , yf-1, zf),grad (bba, xf-1, yf-1, zf),u);
		y1 = lerp(x1, x2, v);

		x1 = lerp(	grad (aab, xf  , yf  , zf-1),grad (bab, xf-1, yf  , zf-1),u);
		x2 = lerp(	grad (abb, xf  , yf-1, zf-1),grad (bbb, xf-1, yf-1, zf-1),u);
		y2 = lerp (x1, x2, v);
		
		ProcedureReturn (lerp (y1, y2, w)+1)/2;						// For convenience we bound it to 0 - 1 (theoretical min/max before is -1 - 1)
	EndProcedure
  
  Procedure DoRepeat(inDR.i = -1) 
	  Static DR.i
		DR = inDR
	EndProcedure
	

	Procedure.d OctavePerlin(x.d,y.d, z.d, octaves.i, persistence.d) 
	  Protected total.d = 0
	  Protected frequency.d = 10
	  Protected amplitude.d = 1
	  Protected maxValue.d = 0 ; Used For normalizing result To 0.0 - 1.0
	  
	  Protected i
	  For i=0 To octaves-1
	    total + perlin(x*frequency,y*frequency,z*frequency)*amplitude
	    maxValue + amplitude
	    amplitude * persistence
	    frequency * 2
	  Next
	  
	  ProcedureReturn total/maxValue
	EndProcedure
  
	Procedure Init()
    Protected i
		For i=0 To #PERMUTATION_SIZE - 1
			PERMUTATION(i)= PeekI(?permutation_table+(x*SizeOf(i))%256)
		Next
	EndProcedure
	
	
	
	
	
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 87
; FirstLine = 72
; Folding = --
; EnableXP
XIncludeFile "../core/Globals.pbi"


XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Time.pbi"
XIncludeFile "../core/Slot.pbi"
XIncludeFile "../core/Perlin2.pbi"
XIncludeFile "../core/Commands.pbi"
XIncludeFile "../core/UIColor.pbi"
XIncludeFile "../core/Pose.pbi"
XIncludeFile "../core/Image.pbi"

XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/GLFW.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../libs/FTGL.pbi"

XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile "../opengl/Texture.pbi"
XIncludeFile "../opengl/ScreenQuad.pbi"
XIncludeFile "../opengl/Context.pbi"
XIncludeFile "../opengl/CubeMap.pbi"

XIncludeFile "../objects/Location.pbi"
XIncludeFile "../objects/Camera.pbi"
XIncludeFile "../objects/Drawer.pbi"
XIncludeFile "../objects/Null.pbi"
XIncludeFile "../objects/Polymesh.pbi"
XIncludeFile "../objects/PointCloud.pbi"
XIncludeFile "../objects/InstanceCloud.pbi"
XIncludeFile "../objects/Light.pbi"
XIncludeFile "../objects/Scene.pbi"
XIncludeFile "../objects/Handle.pbi"
XIncludeFile "../objects/Selection.pbi"
XIncludeFile "../objects/Sampler.pbi"

XIncludeFile "../layers/Layer.pbi"
XIncludeFile "../layers/Default.pbi"
XIncludeFile "../layers/Bitmap.pbi"
XIncludeFile "../layers/Selection.pbi"
XIncludeFile "../layers/GBuffer.pbi"
XIncludeFile "../layers/Defered.pbi"
XIncludeFile "../layers/ShadowMap.pbi"
XIncludeFile "../layers/ShadowSimple.pbi"
XIncludeFile "../layers/ShadowDefered.pbi"
XIncludeFile "../layers/CascadedShadowMap.pbi"
XIncludeFile "../layers/Toon.pbi"
XIncludeFile "../layers/SSAO.pbi"
XIncludeFile "../layers/Blur.pbi"

XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/CompoundPort.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../graph/Nodes.pbi"
XIncludeFile "../graph/Connexion.pbi"
XIncludeFile "../graph/Graph.pbi"
XIncludeFile "../graph/Tree.pbi"

XIncludeFile "../controls/Dummy.pbi"
XIncludeFile "../controls/Button.pbi"
XIncludeFile "../controls/Check.pbi"
XIncludeFile "../controls/Color.pbi"
XIncludeFile "../controls/Combo.pbi"
XIncludeFile "../controls/Divot.pbi"
XIncludeFile "../controls/Edit.pbi"
XIncludeFile "../controls/Label.pbi"
XIncludeFile "../controls/Group.pbi"
XIncludeFile "../controls/Controls.pbi"
XIncludeFile "../controls/Property.pbi"
XIncludeFile "../controls/Menu.pbi"
; XIncludeFile "../controls/PopupMenu.pbi"

XIncludeFile "../commands/Scene.pbi"
XIncludeFile "../commands/Graph.pbi"

XIncludeFile "../ui/View.pbi"
XIncludeFile "../ui/DummyUI.pbi"
XIncludeFile "../ui/LogUI.pbi"
XIncludeFile "../ui/TimelineUI.pbi"
XIncludeFile "../ui/ShaderUI.pbi"
XIncludeFile "../ui/ViewportUI.pbi"
XIncludeFile "../ui/GraphUI.pbi"
XIncludeFile "../ui/PropertyUI.pbi"
XIncludeFile "../ui/ExplorerUI.pbi"
XIncludeFile "../ui/TopMenu.pbi"

CompilerIf #USE_BULLET
  XIncludeFile "../libs/Bullet.pbi"
  XIncludeFile "../bullet/RigidBody.pbi"
  XIncludeFile "../bullet/World.pbi"
  XIncludeFile "../bullet/Constraint.pbi"
CompilerEndIf

CompilerIf #USE_ALEMBIC
  XIncludeFile "../libs/Alembic.pbi"
  XIncludeFile "../objects/Animation.pbi"
CompilerEndIf
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 99
; FirstLine = 24
; EnableXP
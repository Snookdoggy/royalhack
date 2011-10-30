/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DFrame
	
	A window.

*/

PANEL = {}

AccessorFunc( PANEL, "m_bDraggable", 		"Draggable", 		FORCE_BOOL )
AccessorFunc( PANEL, "m_bSizable", 			"Sizable", 			FORCE_BOOL )
AccessorFunc( PANEL, "m_bScreenLock", 		"ScreenLock", 		FORCE_BOOL )
AccessorFunc( PANEL, "m_bDeleteOnClose", 	"DeleteOnClose", 	FORCE_BOOL )

AccessorFunc( PANEL, "m_bBackgroundBlur", 	"BackgroundBlur", 	FORCE_BOOL )


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Init()

	self:SetFocusTopLevel( true )

//	self:SetCursor( "sizeall" )
	
	self.btnClose = vgui.Create( "DSysButton", self )
	self.btnClose:SetType( "close" )
	self.btnClose.DoClick = function ( button ) self:Close() end
	self.btnClose:SetDrawBorder( false )
	self.btnClose:SetDrawBackground( false )
	
	self.lblTitle = vgui.Create( "DLabel", self )
	self.lblTitle:SetTextColor(Color(255,0,0,255))
	
	self:SetDraggable( true )
	self:SetSizable( false )
--	self:SetScreenLock( true )
	self:SetDeleteOnClose( true )
	self:SetTitle( "#Untitled DFrame" )
	
	// This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )
	
	self.m_fCreateTime = SysTime()

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:ShowCloseButton( bShow )

	self.btnClose:SetVisible( bShow )

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:SetTitle( strTitle )

	self.lblTitle:SetText( strTitle )

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Close()

	self:SetVisible( false )

	if ( self:GetDeleteOnClose() ) then
		self:Remove()
	end

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Center()

	self:InvalidateLayout( true )
	self:SetPos( ScrW()/2 - self:GetWide()/2, ScrH()/2 - self:GetTall()/2 )

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Think()

	if (self.Dragging) then
	
		local x = gui.MouseX() - self.Dragging[1]
		local y = gui.MouseY() - self.Dragging[2]

		// Lock to screen bounds if screenlock is enabled
	--	if ( self:GetScreenLock() ) then
		
		--	x = math.Clamp( x, 0, ScrW() - self:GetWide() )
			--y = math.Clamp( y, 0, ScrH() - self:GetTall() )
		
	--	end
		
		self:SetPos( x, y )
	
	end
	
	
	if ( self.Sizing ) then
	
		local x = gui.MouseX() - self.Sizing[1]
		local y = gui.MouseY() - self.Sizing[2]	
	
		self:SetSize( x, y )
		self:SetCursor( "sizenwse" )
		return
	
	end
	
	if ( self.Hovered &&
         self.m_bSizable &&
	     gui.MouseX() > (self.x + self:GetWide() - 20) &&
	     gui.MouseY() > (self.y + self:GetTall() - 20) ) then	

		self:SetCursor( "sizenwse" )
		return
		
	end
	
	if ( self.Hovered && self:GetDraggable() ) then
		self:SetCursor( "sizeall" )
	end
	
end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Paint()

	if ( self.m_bBackgroundBlur ) then
		Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
	end
	surface.SetDrawColor(41,41,41,255)
	surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	surface.SetDrawColor(0,0,0,255)
	surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
	surface.SetDrawColor(41,41,41,255)
	surface.DrawRect(0,0,self:GetWide(),21)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawOutlinedRect(0,0,self:GetWide(),21)

	return true

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:OnMousePressed()

	if ( self.m_bSizable ) then
	
		if ( gui.MouseX() > (self.x + self:GetWide() - 20) &&
			gui.MouseY() > (self.y + self:GetTall() - 20) ) then			
	
			self.Sizing = { gui.MouseX() - self:GetWide(), gui.MouseY() - self:GetTall() }
			self:MouseCapture( true )
			return
		end
		
	end
	
	if ( self:GetDraggable() ) then
		self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
		self:MouseCapture( true )
		return
	end
	


end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:OnMouseReleased()

	self.Dragging = nil
	self.Sizing = nil
	self:MouseCapture( false )

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:PerformLayout()

	derma.SkinHook( "Layout", "Frame", self )

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:IsActive()

	if ( self:HasFocus() ) then return true end
	if ( vgui.FocusedHasParent( self ) ) then return true end
	
	return false

end


derma.DefineControl( "RoyalFrame", "A Custom Derma Skin", PANEL, "EditablePanel" )
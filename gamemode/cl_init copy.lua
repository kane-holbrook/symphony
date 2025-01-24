include("shared.lua")

sym.fonts = {}
sym.fonts.default = sym.Font()
sym.fonts.h1 = sym.Font("Oxanium ExtraBold", 35)
sym.fonts.h2 = sym.Font("Oxanium ExtraBold", 28)
sym.fonts.h3 = sym.Font("Oxanium ExtraBold", 25)
sym.fonts.p = sym.Font(18)
sym.fonts.p_bold = sym.Font("Oxanium ExtraBold", 18)

local PANEL = {}
function PANEL:Init()
    if IsValid(MAIN_MENU) then
        MAIN_MENU:Remove()
    end

    MAIN_MENU = self

    self:SetSizeEx(REL(1), REL(1))
    self:SetBackground(color_black)

    self:Page2()
    
end

function PANEL:Page1()
    if IsValid(self.Page) then
        self.Page:Remove()
    end 
    
    surface.PlaySound("sstrp/tbx/menu/intro.mp3")

    self.Page = vgui.Create("DHTML", self)
    self.Page:SetHTML([[
        <link href="https://fonts.googleapis.com/css2?family=Oxanium:wght@200;300;400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            * {
                color: white;
                user-select: none;
                pointer-events: none;
                overflow: hidden;
                font-family: 'Oxanium', sans-serif;
                font-size: 22px;
            }

            body {
                overflow: hidden;
                width:100%;
                height:100%;
            }
            
            .title {
                display:none;
                opacity: 0;
                text-align: center;
                animation: fadeInOut 30s cubic-bezier(0.25, 0.1, 0.25, 1) forwards;
                font-size: 3em;
            }

            @keyframes fadeInOut {
                0% {
                    opacity: 0;
                    transform: scale(0.5);
                }
                20% {
                    opacity: 1;
                    transform: scale(1.3);
                }
                80% {
                    opacity: 1;
                    transform: scale(1.4);
                }
                100% {
                    opacity: 0;
                    transform: scale(0.8);
                }
            }
        </style>
        <script src="https://code.jquery.com/jquery-3.7.1.min.js" crossorigin="anonymous"></script>

        <body style="display: flex; flex-direction: column; height: 100%; width: 100%; align-items: center; justify-content: center;">
            <img id="item_0" src="https://sstrp.net/static/logo.png" style="opacity:0; height: 10em; margin-bottom: 6em;" />
            <div id="pg1" style="max-width:700px;">    
                <p style="opacity:0;" id="item_1">In 2168, a company of Mobile Infantrymen were ordered to stand by whilst their home planet of Brightsky was ravaged by the Skinnies, a race of hostile aliens.</p>
                <p style="opacity:0;" id="item_2">Instead they mutinied and against all odds prevailed, defeating the invaders.</p>
                <p style="opacity:0;" id="item_3">Despite their heroism, the Federation branded them traitors.</p>
                <p style="opacity:0;" id="item_4">Today, they roam the outer rims of Federation space, doing what they can to survive, offering their services to frontier colonies in need — or whomever can pay for it.</p>
                <p style="opacity:0;" id="item_5">They're never more than a couple of steps ahead of the Federation.</p>
                <p style="opacity:0;" id="item_6">This is their story.</p>
                <p style="opacity:0;" id="item_7">These are their chronicles.</p>
            </div>

            <div class="title" style="position: absolute; top: 20%; transform: translateY(-50%);">
                <img src="https://sstrp.net/static/logo.png" style="height: 3em; margin-bottom: 2em;" />
            
                <p style="font-size: 80%; margin:0">THE</p>
                <p style="font-size: 250%; font-weight:bold; margin:0">BLACK CROSS</p>
                <p style="font-size: 100%; margin:0">CHRONICLES</p>
            </div>

            <script>

                function fadeIn(selector, time) {
                    setTimeout(() => {
                        $(selector).css('transition', 'opacity 2s');
                        $(selector).css('opacity', '1');
                    }, time);
                }

                function fadeOut(selector, time) {
                    setTimeout(() => {
                        $(selector).css('transition', 'opacity 2s');
                        $(selector).css('opacity', '0');
                    }, time);
                }

                function showSplashScreen() {
                    $('.title').show();
                    $('.title').css({ opacity: 0 }).animate({ opacity: 1 }, 5000, function () {
                        setTimeout(() => {
                            $('.title').animate({ opacity: 0 }, 1000);
                        }, 14000);
                    });
                    
                }
                function hideSplashScreen() {
                    $("#pg2").css({
                        'opacity': '1',
                        'transform': 'scale(1) translateY(0)'
                    });
                }

                fadeIn("#item_0", 500);
                fadeIn("#item_1", 3000);
                fadeIn("#item_2", 9000);
                fadeIn("#item_3", 13000);
                fadeIn("#item_4", 18000);
                fadeIn("#item_5", 24000);
                fadeIn("#item_6", 30000);
                fadeIn("#item_7", 33500);

                // Fade out all items at 40 seconds
                setTimeout(() => {
                    fadeOut("#item_0", 0);
                    fadeOut("#item_1", 0);
                    fadeOut("#item_2", 0);
                    fadeOut("#item_3", 0);
                    fadeOut("#item_4", 0);
                    fadeOut("#item_5", 0);
                    fadeOut("#item_6", 0);
                    fadeOut("#item_7", 0);
                    setTimeout(showSplashScreen, 3000); // Show splash screen after items fade out
                }, 43000);

            </script>
        </body>
    ]])
    self.Page:Dock(FILL)
end

function PANEL:Page2()
    if IsValid(self.Page) then
        self.Page:Remove()
    end 

    local RadioController = sym.RadioGroup()
    local ChkController = sym.CheckboxGroup()

    self:AddEx({
        Dock = FILL,
        Flex = 5,
        FlexFlow = FLEX_FLOW_Y
    })

        :AddEx("SymFrame", {
            Ref = "Frame",
            SizeEx = { REL(0.5), REL(0.8) },
            Flex = 5,
            FlexFlow = FLEX_FLOW_Y
        })
            
            :AddEx({
                Ref = "Content",
                FlexGrow = true,
                FlexMargin = { SS(4) },
                Flex = 7,
                FlexFlow = FLEX_FLOW_Y,
                FlexGap = SS(2)
            })
            

                :AddEx("SymScroll", { 
                    FlexGrow = true,
                    FlexMargin = { 0, 0, 0, 0 } 
                })

                    :Add("SymLabel", {
                        Text = "UI Test",
                        Font = sym.fonts.h1
                    })

                    :Add("SymWrapLabel", {
                        Text = "A collection of different UI components for testing.",
                        SizeEx = { REL(1) },
                        Font = sym.fonts.p,
                        FlexMargin = { 0, 0, 0, SSH(5) }
                    })
                    
                    :AddEx("SymPanel", { Flex = 4, 
                    FlexMargin = { 0, 0, 0, 0 } })

                        :Add("SymLabel", {
                            Text = "Panel",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

                    
                    
                    :AddEx("SymPanel", { Flex = 4, 
                    FlexMargin = { 0, 0, 0, 0 } })

                        :Add("SymLabel", {
                            Text = "Typography",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

                    
                    :Add("SymWrapLabel", {
                        Text = "H1: The quick brown fox jumps over the lazy dog",
                        Font = sym.fonts.h1,
                        FlexMargin = { 0, SS(5), 0, 0 },
                        SizeEx = { REL(1), CHRH(sym.fonts.h1) }
                    })
                    
                    :Add("SymWrapLabel", {
                        Text = "H2: The quick brown fox jumps over the lazy dog",
                        Font = sym.fonts.h2,
                        FlexMargin = { 0, SS(5), 0, 0 },
                        SizeEx = { REL(1), CHRH(sym.fonts.h2) }
                    })
                    
                    :Add("SymWrapLabel", {
                        Text = "H3: The quick brown fox jumps over the lazy dog",
                        Font = sym.fonts.h3,
                        FlexMargin = { 0, SS(5), 0, 0 },
                        SizeEx = { REL(1), CHRH(sym.fonts.h3) }
                    })
                    
                    :Add("SymWrapLabel", {
                        Text = "The quick brown fox jumps over the lazy dog",
                        Font = sym.fonts.p,
                        FlexMargin = { 0, SS(6), 0, 0 },
                        SizeEx = { REL(1), CHRH(sym.fonts.h3) }
                    })

                    :AddEx("SymPanel", { Flex = 4, 
                    FlexMargin = { 0, SS(5), 0, 0 },
                    FlexGap = 0 })

                        :Add("SymLabel", {
                            Text = "The ",
                            Font = sym.fonts.p
                        })

                        :Add("SymLabel", {
                            Text = "quick",
                            Font = sym.fonts.p,
                            Background = color_white,
                            Color = color_black
                        })

                        :Add("SymLabel", {
                            Text = " brown ",
                            Font = sym.fonts.p_bold
                        })

                        :Add("SymLabel", {
                            Text = "fox",
                            Font = sym.fonts.h3
                        })

                        :Add("SymLabel", {
                            Text = " jumps ",
                            Font = sym.fonts.p,
                            Color = Color(255, 255, 0, 255)
                        })

                        :Add("SymSprite", {
                            Material = "symphony/logo64.png",
                            SizeEx = { SSH(10), SSH(10) },
                            FlexMargin = { 0, 0, CHRW(sym.fonts.p), 0 }
                        })

                        :Add("SymLabel", {
                            Text = " over the lazy dog ",
                            Font = sym.fonts.p,
                            FlexMargin = { 0, 0, CHRW(sym.fonts.p), SS(5) }
                        })

                        
                        :SizeToChildren(true, true)
                        :GetParent()

                    :AddEx("SymPanel", { Flex = 4, 
                    FlexMargin = { 0, SS(5), 0, 0 } })

                        :Add("SymLabel", {
                            Text = "Frame",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

                    
                    :AddEx("SymPanel", { Flex = 4, 
                    FlexMargin = { 0, 0, 0, 0 } })

                        :Add("SymLabel", {
                            Text = "Scroll",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

                    
                    :AddEx("SymPanel", { Flex = 4, 
                    FlexMargin = { 0, 0, 0, 0 } })

                        :Add("SymLabel", {
                            Text = "Buttons",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()
                    
                        -- @issue: FlexMargin top not being added to total y, only to element.
                    :AddEx("SymButton", {
                        Content = { 
                            "A ",
                            SymLabel(nil, "button", 
                                sym.Font("Oxanium ExtraBold", 25, 500, {
                                    Underline = true,
                                    BlurSize = 33
                                }), 
                                { Background = Color(255, 0, 0, 192) }
                            ), 
                            " with a right aligned image! ", 
                            Material("symphony/logo64.png") 
                        },
                        FlexMargin = { 0, 0, 0, SS(5) },
                        FlexGap = 0,
                        Click = function (p)
                            p:SetDisplay(DISPLAY_NONE)
                            timer.Simple(1.0, function ()
                                p:SetDisplay(DISPLAY_VISIBLE)
                            end)
                        end
                    })
                        :SizeToChildren(true, true, SS(5), SS(5))
                        :GetParent()
                        
                        

                    
                    :AddEx("SymPanel", { Flex = 4, 
                    FlexMargin = { 0, 0, 0, 0 } })

                        :Add("SymLabel", {
                            Text = "Text boxes",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()
                    
                    :Add("SymInputText", {
                        SizeEx = { SS(150), SSH(20) },
                        FlexMargin = { 0, 0, 0, 0 },
                        PlaceholderText = "This is a textbox"
                    })
                    
                    :AddEx("SymInputText", {
                        SizeEx = { SS(150), SSH(20) },
                        FlexMargin = { 0, 0, 0, SS(5) },
                        PlaceholderText = "This is a textbox with elements to the right."
                    })

                        :Add("SymSprite", {
                            Material = "symphony/logo64.png",
                            SizeEx = { SSH(10), SSH(10) },
                            FlexMargin = { 0, 0, SS(3), 0 },
                            Cursor = "hand"
                        })

                        :Add("SymSprite", {
                            Material = "symphony/logo64.png",
                            SizeEx = { SSH(10), SSH(10) },
                            FlexMargin = { 0, 0, SS(3), 0 },
                            Rotation = 90,
                            Color = Color(255, 255, 255, 64),
                            Cursor = "hand"
                        })

                        :GetParent()

                    
                        
                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Text areas",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()
                        
                    :Add("SymInputText", {
                        SizeEx = { SS(150), SSH(60) },
                        FlexMargin = { 0, 0, 0, 0 },
                        PlaceholderText = "This is a text area",
                        Multiline = true
                    })

                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Combobox",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

                    :AddEx("SymInputSelect", {
                        SizeEx = { SS(150), SSH(20) },
                        FlexMargin = { 0, 0, 0, 0 },
                        PlaceholderText = "This is a select/dropdown",
                        AllowText = true
                    })
                        :AddItem("Xalphox")
                        :AddItem("Argon")
                        :AddItem("Fred")

                        :GetParent()
                    

                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Select",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

                    
                    :AddEx("SymInputSelect", {
                        SizeEx = { SS(150), SSH(20) },
                        FlexMargin = { 0, 0, 0, 0 },
                        PlaceholderText = "This is a select/dropdown"
                    })
                        :AddItem("Xalphox")
                        :AddItem("Argon")
                        :AddItem("Fred")

                        :GetParent()

                        

                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Slider",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

                    :Add("SymInputSlider", { SizeEx = { REL(1) }, Value = 128, Bounds = { 0, 256} })

                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Checkbox",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()
                    
                    :Add("SymInputCheckbox", { Controller = { ChkController, "Checkbox_1" }, Label = "This is checkbox 1" })
                    :Add("SymInputCheckbox", { Controller = { ChkController, "Checkbox_2" }, Label = "This is checkbox 2" })
                    :Add("SymInputCheckbox", { Controller = { ChkController, "Checkbox_3" }, Label = "This is checkbox 3" })
                    :Add("SymInputCheckbox", { Controller = { ChkController, "Checkbox_4" }, Label = "This is checkbox 4" })
                    :Add("SymInputCheckbox", { Controller = { ChkController, "Checkbox_5" }, Label = "This is checkbox 5" })

                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Radio button",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

                    :Add("SymInputRadio", { Controller = { RadioController, "Radio_1" }, Label = "This is radio 1" })
                    :Add("SymInputRadio", { Controller = { RadioController, "Radio_2" }, Label = "This is radio 2" })
                    :Add("SymInputRadio", { Controller = { RadioController, "Radio_3" }, Label = "This is radio 3" })
                    :Add("SymInputRadio", { Controller = { RadioController, "Radio_4" }, Label = "This is radio 4" })
                    :Add("SymInputRadio", { Controller = { RadioController, "Radio_5" }, Label = "This is radio 5" })
                                      
                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Colour picker",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✕",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(255, 0, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

                    
                    :AddEx("SymInputColor", {
                        SizeEx = { SS(150), SSH(20) },
                        FlexMargin = { 0, 0, 0, 0 }
                    })

                        :GetParent()

                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Context menu",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✕",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(255, 0, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

                        

                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Modal",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 },
                            Cursor = "hand",
                            NoHover = false,
                            Click = function (p)
                                print("Open!")
                                p:GetParent().Modal:Open()
                            end
                        })

                        :AddEx("SymModal", { Ref = "Modal" })
                            
                            :Add("SymLabel", {
                                Text = "This is a modal dialog!",
                                Font = sym.fonts.h1
                            })
                            
                            :Add("SymLabel", {
                                Text = "Are you sure you want to do this action or whatever?",
                                Font = sym.fonts.p
                            })

                            :GetParent()

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

                    :AddEx("SymPanel", { Flex = 4 })

                        :AddEx("SymLabel", {
                            Text = "Popover",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 },
                            NoHover = false,
                            Cursor = "hand",
                            Click = function (p)
                                if p.Popover:IsOpen() then
                                    p.Popover:Close()
                                else
                                    p.Popover:Open()
                                end
                            end
                        })

                            :AddEx("SymPopover", { On = "click", Alignment = 6 })
                                :Add("SymPanel", { 
                                        SizeEx = { SS(300), SS(300) },
                                        Background = sym.CreateMaterial()
                                            :AddBoxGradient({ 
                                                0, Color(40, 48, 56, 255),
                                                0.7, Color(11, 20, 27, 255), 
                                                1, Color(11, 20, 27, 255)
                                            })
                                            :Generate()
                                    })
                                :GetParent()

                            :GetParent()

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()
                        
                        

                    :AddEx("SymPanel", { Flex = 4 })

                        :AddEx("SymLabel", {
                            Text = "Tool tip",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 },
                            NoHover = false,
                            Cursor = "hand"
                        })

                            :Add("SymTooltip", {
                                Content = "Hello world!",
                                Alignment = 8
                            })
                            :GetParent()

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()
                        

                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Info",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        

                        :Add("SymInfo", {
                            Content = "Tooltip left",
                            Alignment = 4,
                            FlexMargin = { SS(2), SS(5), 0, 0 }
                        })

                        :Add("SymInfo", {
                            Content = "Tooltip top",
                            Alignment = 8,
                            FlexMargin = { SS(2), SS(5), 0, 0 }
                        })

                        :Add("SymInfo", {
                            Content = "Tooltip right",
                            Alignment = 6,
                            FlexMargin = { SS(2), SS(5), 0, 0 }
                        })

                        :Add("SymInfo", {
                            Content = "Tooltip bottom",
                            Alignment = 2,
                            FlexMargin = { SS(2), SS(5), 0, 0 }
                        })

                        :Add("SymInfo", {
                            Content = "Floating",
                            Alignment = 5,
                            FlexMargin = { SS(2), SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Key button",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✓",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(0, 255, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()
                        
                    :AddEx("SymPanel", { Flex = 4, FlexGap = SS(1) })
                        
                        :Add("SymKey", {
                            Content = { 
                                "Q"
                            },
                            SizeEx = { SS(10), SS(10) },
                            FlexGap = 0,
                            Click = function (p)
                                p:SetDisplay(DISPLAY_NONE)
                                timer.Simple(1.0, function ()
                                    p:SetDisplay(DISPLAY_VISIBLE)
                                end)
                            end
                        })
                        
                        :Add("SymKey", {
                            Content = { 
                                "E"
                            },
                            SizeEx = { SS(10), SS(10) },
                            FlexGap = 0,
                            Click = function (p)
                                p:SetDisplay(DISPLAY_NONE)
                                timer.Simple(1.0, function ()
                                    p:SetDisplay(DISPLAY_VISIBLE)
                                end)
                            end
                        })
                        
                        :Add("SymKey", {
                            Content = { 
                                "CTRL+A"
                            },
                            SizeEx = { SS(25), SS(10) },
                            FlexGap = 0,
                            Click = function (p)
                                p:SetDisplay(DISPLAY_NONE)
                                timer.Simple(1.0, function ()
                                    p:SetDisplay(DISPLAY_VISIBLE)
                                end)
                            end
                        })

                        :SizeToChildren(true, true)
                        :GetParent()

                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Line graph",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✕",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(255, 0, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()
                        

                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Tree",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✕",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(255, 0, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Accordion/list",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✕",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(255, 0, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Draggable/sortable",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✕",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(255, 0, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()
                        
                    :AddEx("SymPanel", { Flex = 4, SizeEx = { REL(0.8), SSH(150) }, FlexGap = SS(5) })

                        :Add("SymPanel", { SizeEx = { REL(0.5), REL(1) }, Background = Color(64, 64, 0, 255) })
                        :Add("SymPanel", { SizeEx = { REL(0.5), REL(1) }, Background = Color(0, 0, 64, 255) })
                        
                        :GetParent()

                    :AddEx("SymPanel", { Flex = 4 })

                        :Add("SymLabel", {
                            Text = "Transitions",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })

                        :Add("SymLabel", {
                            Text = " ✕",
                            Font = sym.Font("Oxanium Extrabold", 22),
                            Color = Color(255, 0, 0, 255),
                            FlexMargin = { 0, SS(5), 0, 0 }
                        })
                        
                        :SizeToChildren(true, true)
                        :GetParent()

        ChkController:SetValue("Checkbox_1", true)
        ChkController:SetValue("Checkbox_3", true)
        RadioController:SetValue("Radio_3")
        --[[]
        self.Page:Add("SymFrame", {
            Ref = "Frame",
            SizeEx = { REL(0.5), REL(0.5) },
            Flex = 5
        })

        surface.CreateFont("TestFont", {
            font = "Oxanium",
            size = 25,
            weight = 500
        })

        surface.CreateFont("TestFont2", {
            font = "Oxanium",
            size = 50,
            weight = 500
        })

        self.Page:Add("SymButton", {
            Ref = "Next",
            SizeEx = { SS(50), SSH(25) },
            FlexMargin = { 0, SSH(15), 0, 0 },
            Flex = 5,
            Content = {
                Material("symphony/logo64.png"),
                "ABC DEF GHI"
            },
            Click = function ()
                self:Remove()
            end
        })

            --[[self.Page.Next:Add("SymSprite", {
                Ref = "Sprite",
                Material = "symphony/logo64.png",
                SizeEx = { CHRH("TestFont", "0"), CHRH("TestFont", "0") },
                FlexMargin = { 0, 0, CHRW("TestFont", "0"), 0 }
            })

            self.Page.Next:Add("SymText", {
                Text = "ABC DEF GHI",
                Font = "TestFont",
                --FlexMargin = { 0, SS(2), CHRW("TestFont", "0"), SS(2) }
            })--]]

        --self.Page.Next:SizeToChildren(true, true, SS(5), SS(5))
    
end
vgui.Register("SymMainMenu", PANEL, "SymPanel")
--vgui.Create("SymMainMenu")
--MAIN_MENU:MakePopup()
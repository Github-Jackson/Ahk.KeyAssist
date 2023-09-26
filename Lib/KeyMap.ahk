#Include <Map>
#Include <Key>
#Include <Function>
#Include <InI>
#Include <Hotkey>
#Include <WinActive>
#Include <Application>
#Include <Script>
#Include <Dynamic>
#Include <Windows\WindowSugar>
#Include <Windows\ProcessSugar>

class KeyMap{
	static Modifier := new Map()
	static action:={}
	static press:={}
	static LongMappingDetectionDelay := 20
	__New(filePath){
		this.filePath:=filePath
		SplitPath, % filePath ,, dir,, name
		name:=this._Replace(name,Application.Config.NameReplace)
		dir:=this._Replace(dir,Application.Config.PathReplace)

		if(dir){
			this.active:=new WinActive(dir)
		}
		ini:= new InIReader(filePath)
		if((this.Name:=name)){
			if(!KeyMap.Modifier.HasKey(dir)){
				_director:= new HotkeyDirector(this.active)
				_director.On(1)
				KeyMap.Modifier.Put(dir,_director)
			}
			
			try {
				h:=KeyMap.Modifier[dir].Put("*" name " Up",this).list.On(1)
			}
			return this.Register(ini)
		}
		this.decor:=new HotkeyDecorator(this.Name,this.active).On(1)
		for k,v in ini {
			new this.KeySection(k,v,this)
		}
	}
	_Replace(e,replaceMap){
		for k,v in replaceMap{
			e:=StrReplace(e,k,v)
		}
		return e
	}
	Register(ini){
		this._keyStates:={"":new KeyState(this.name)}

		for k,v in ini {
			; 如果section name 存在@|& 收集域中的所有热键
			if(InStr(k,"@")||InStr(k,"&"))
				this._keyStates[k]:=this.GetKeyState(v)
			this.decor:=new HotkeyDecorator(this.GetAction.Bind(this,k),this.active).On(1)
			new this.KeySection(k,v,this)
		}
	}
	GetAction(e){
		result:=0
		if(InStr(e,"&"))
			result:=result||KeyMap.action[this.Name]
		if(InStr(e,"@"))
			result:=result||this["@"]
		return result||this._keyStates[""].Call()
	}
	; 以文件名注册热键成功后的按键抬起事件的处理函数
	; 如Capslock.ini => Hotkey("*Capslock Up")
	Call(){
		Sleep % this.LongMappingDetectionDelay
		;修饰键抬起时 遍历检测持续映射相关按键是否被按下
		for k,v in this._keyStates {
		; 如果存在持续映射态, 设置持续映射
			;@LOG("[" this.filePath "]" k ":" v._e "==" v.Call() "`n")
			if(v.Call()){
				return !this.Control(k)
			}
		}
		; 否则重置持续映射
		this["@"]:=KeyMap.action[this.Name]:=0
		;检测全局同名(同一个按键)修饰键下是否触发过按键映射(热键)
		;若触发过,press为1, 则屏蔽修饰键
		;若press为0 则发送Application.Config [Modifier]中修饰键对应的映射键
		if(KeyMap.press[this.Name]){
			;重置press
			this.SetPress(0)
			return 0
		}else {
			return true
		}
	}
	Sending(){
		this.SetPress()
	}
	SetPress(state:=1){
		KeyMap.press[this.Name]:=state
	}
	Control(section){
		result:= 0
		;设置文件内的持续映射
		if(InStr(section,"@"))
			result:= this["@"]:=1
		;设置全局同名文件的持续映射
		if(InStr(section,"&"))
			result:= KeyMap.action[this.Name]:=1
		return result
	}
	GetKeyState(o){
		temp:="_"
		for k,v in o
			temp.="|" k
		return new KeyState(temp)
	}
	Class KeySection{
		static SendAss:={modify:{"~":"~","*":"*"},mode:{"%":"{Raw}","#":"{Text}","*":"{Blind}"}}
		static toggle_regex:="OS){@(.+?)( [+-]?\d+)?}" ;用于匹配Send 中的{@name}
		static send_level_regex:="OS)\+(\d+)" ;用于匹配Section 中的SendLevel
		static input_level_regex:="OS)-(\d+)" ;用于匹配Section 中的InputLevel
		static key_delay_regex:="iOS)\(([\d,play]+)\)" ;用于匹配Section 中的(delay,duration,'Play')
		__New(name,section,parent){
			this.parent:=parent
			this.sectionname:=name
			decor:=parent.decor

			;判断section是否存在:, 若存在添加新的限定条件
			if(InStr(name,":")){
				condition:= StrSplit(name,":")
				name:=condition[1]
				decor:=parent.decor.Clone()
				decor.InsertAt(1,new KeyState(condition[2]))
			}

			this._Initial(name)
			;SendLevel
			this.send_level:=0
			if(RegExMatch(name,this.send_level_regex,match)){
				this.send_level:=match[1]
			}else if(Application.Config.Setting.SendLevel){
				this.send_level:=Application.Config.Setting.SendLevel
			}

			;Hotkey - InputLevel
			linput:=""
			if(RegExMatch(name, this.input_level_regex,match)){
				linput:=match[1]
			}
			;KeyDelay
			if(RegExMatch(name, this.key_delay_regex, match)){
				this.key_delay:=StrSplit(match[1],",")
			}

			; 收集toggle 键值对
			this.toggle:={}

			HotkeyIf(decor)
			for k,v in section{
				index:=1,init:=1
				loop
				{
					if(index:=RegExMatch(v,this.toggle_regex,match,index)){
						if(init){
							this.toggle[k]:={},init:=0
						}
						index++
						this.toggle[k][match[1]]:=match[2]
						if(!KeyState.toggle[match[1]]){
							KeyState.toggle[match[1]]:=0
						}
					}else{
						break
					}
				}
				if(InStr(k,":")==1){
					handle:=v
					if(InStr(name,"$") or InStr(name,"^") or InStr(name,"!")){
						handle:=this.Call.Bind(this,k,this.mode . v)
					}else if(InStr(name,"?")){
						handle:=this.Call.Bind(this,k,this.mode . v)
					}else{
						handle:=v
					}
					Hotstring(k,handle)
				}else{
					if(linput==""){
						Hotkey(this.prev . k,this.Call.Bind(this,k,this.mode . v))
					}else{
						Hotkey(this.prev . k,this.Call.Bind(this,k,this.mode . v),"I" linput)
					}
				}
				;@LOG("$Register(" k "=" v "`t`t of: <" this.parent.filepath  ">--[" this.sectionname "]`n")
			}
			HotkeyIf()
			;@LOG("#InputLevel=" linput "`t`t of: <" this.parent.filepath  ">--[" this.sectionname "]`n")
		}
		_Initial(name){
			for k,v in this.SendAss.modify {
				if(InStr(name,k))
					this.prev.=v
			}
			;判断section 是否存在?, 若存在则设置该域下所有右侧表达式为执行模式
			if(InStr(name,"?")){
				this._Send:=this.DynamicCall
				return
			}
			if(InStr(name,"!"))
				this._Send:=this.SendPlay
			if(InStr(name,"^"))
				this._Send:=this.SendInput
			if(InStr(name,"$"))
				this._Send:=this.SendEvent

			for k,v in this.SendAss.mode
				if(InStr(name,k))
					this.mode:=v . this.mode
		}
		Call(key,value){
			this.Send(value)
			if(this.toggle[key]){
				for k,v in this.toggle[key]{
					if(v==""){
						KeyState.toggle[k]:=!KeyState.toggle[k]
					}else if(v==0){
						KeyState.toggle[k]:=0
					}else if(InStr(v,"+")){
						KeyState.toggle[k]+=v
					}else if(v<0){
						KeyState.toggle[k]+=v
					}else{
						KeyState.toggle[k]:=v
					}
					if(KeyState.toggle[k]<=0){
						KeyState.toggle[k]:=0
					}
				}
				if(KeyState.toggle["log"])
					@LOG("@TOGGLE[" k "]=" KeyState.toggle[k] "`t`t `n")
			}
			if(KeyState.toggle["log"])
				@LOG(key "`t=`t" value "`n`t`t`t <" this.parent.filepath ">`t`t[" this.sectionname "]`n")
		}
		Send(value){
			this.parent.Sending()
			if(this.key_delay){
				SetKeyDelay(this.key_delay*)
			}
			SendLevel % this.send_level
			this._Send(value)
		}
		DynamicCall(expression){
			DynamicCall(expression)
		}
		_Send(v){
			Send %v%
		}
		SendInput(v){
			SendInput %v%
		}
		SendEvent(v){
			SendEvent %v%
		}
		SendPlay(v){
			SendPlay %v%
		}
	}
}
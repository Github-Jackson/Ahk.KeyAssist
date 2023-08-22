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
				KeyMap.Modifier.Put(dir,new HotkeyDirector(this.active))
			}
			
			try {
				h:=KeyMap.Modifier[dir].Put("*" name " Up",this).list.Call:=this.CallAll
			}
			return this.Register(ini)
		}
		this.decor:=new HotkeyDecorator(this.Name,this.active).On(1)
		for k,v in ini {
			new this.KeySection(k,v,this)
		}
	}
	CallAll(){
		result:=1
		for k,v in this.list
			result&=v.Call()
		return result
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
	
	Call(){
		Sleep % this.LongMappingDetectionDelay
		for k,v in this._keyStates
			if(v.Call())
				return !this.Control(k)
		if(KeyMap.press[this.Name]){
			this.SetPress(0)
			this["@"]:=KeyMap.action[this.Name]:=0
		}
		else {
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
		if(InStr(section,"@"))
			return this["@"]:=1
		if(InStr(section,"&"))
			return KeyMap.action[this.Name]:=1
		return 1
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
		static send_level_regex:="OS)\((\d+)\)"
		__New(name,section,parent){
			this.parent:=parent
			this.sectionname:=name
			decor:=parent.decor

			;判断section是否存在:, 若存在添加新的限定条件
			if(InStr(name,":")){
				condition:= StrSplit(name,":")
				name:=condition[1]
				decor:=parent.decor.Clone()
				decor.Push(condition[2])
			}

			this._Initial(name)
			;SendLevel
			level:=0
			if(RegExMatch(name,this.send_level_regex,match)){
				level:=match[1]
			}else if(Application.Config.Setting.SendLevel){
				level:=Application.Config.Setting.SendLevel
			}
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
						handle:=this.Hotstring.Bind(this,k,this.mode . v,level)
					}else if(InStr(name,"?")){
						handle:=this.Hotstring.Bind(this,k,this.mode . v,level)
					}else{
						handle:=v
					}
					Hotstring(k,handle)
				}else{
					Hotkey(this.prev . k,this.Call.Bind(this,k,this.mode . v),"I" level)
				}
			}
			HotkeyIf()
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
					@LOG("@[" this.sectionname "]`t`t`t @TOGGLE[" k "]=" KeyState.toggle[k] "`n")
				}
			}
			@LOG("[" this.sectionname "]`t`t" key "=" value "`t of:`t[" this.parent.filepath  "]`n")
		}
		Send(value){
			this.parent.Sending()
			this._Send(value)
		}
		Hotstring(key,value,level:=0){
			SendLevel, %level%
			this.Call(key,value)
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
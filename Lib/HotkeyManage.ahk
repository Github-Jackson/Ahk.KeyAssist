class HotkeyManage{
	static manage:=""
	__New(){
		if(HotkeyManage.manage=="")
			HotkeyManage.manage:=new this.HotkeyManager()
		return HotkeyManage.manage
	}
	class HotkeyManager{
		hotkeys:={}
		Register(key,fun*){
			if(!key)
				return
			if(!this.hotkeys[key]){
				temp:=this.hotkeys[key]:=new this.Hotkey(key,fun*)
				Hotkey,*%key% Up,% temp
			}else 
				this.hotkeys[key].Push(fun*)
			return this
		}
		OnSuccess(key,fn){
			this.hotkeys[key].OnSuccess(fn)
		}
		
		class Hotkey{
			__New(key,fun*){
				this.key:=key
				this.queue:=[]
				this.Push(fun*)
			}
			_NewEnum(){
				return this.queue._NewEnum()
			}
			Call(params*){
				result:=1
				for k,v in this.queue
					result&=v.Call(params*)
				if(result)
					this.success.Call(params*)
			}
			Push(fun*){
				this.queue.Push(fun*)
				return this
			}
			OnSuccess(fn){
				this.success:=fn
				return this
			}
			
			On(){
				return this._Control("On")
			}
			Off(){
				return this._Control("Off")
			}
			Toggle(){
				return this._Control("Toggle")
			}
			_Control(c){
				key:=this.key
				Hotkey,%key%,%c%
				return this
			}
			Options(option){
				key:=this.key
				Hotkey,%key%,,%option%
				return this
			}
		}

	}
	
}
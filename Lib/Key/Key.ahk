Class Key{
	__New(key){
		this.key:=key
	}
	GetName(){
		return GetKeyName(this.key)
	}
	GetVK(){
		return GetKeyVK(this.key)
	}
	GetSC(){
		return GetKeySC(this.key)
	}
	GetState(mode*){
		return GetKeyState(this.key,mode*)
	}
	static State:=KeyState
}
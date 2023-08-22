class WinActive{
  __New(match){
    this.match:=match
  }

  Call(){
    return WinActive(this.match)
  }
}
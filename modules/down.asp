<%@LANGUAGE="vbscript" CodePage="65001" %>
<%Response.Charset = "utf-8"%>
<%  
	Response.Buffer = True
		filename = Request.QueryString("file")
		path     = Request.QueryString("path")
		filepath = Server.MapPath(path)&"\"& Request.QueryString("file")
	if isFileNotExist(filepath) then
	    Response.write messageBack("존재하지 않는 파일입니다.")
        Response.end
	End if
	Dim arrFileType
	Dim notUpType : notUpType = "asp,php,jsp,aspx,cgi,exe,js,css" '업로드가 허용 안돼는 파일타입
	Dim notUpChk : notUpChk = false
	Dim fileType : fileType = Mid(filename, InStrRev(filename, ".") + 1)
	 arrFileType = Split(notUpType, "," ) 

	For i = 0 To Ubound(arrFileType) 
		If UCase(fileType) = UCase(arrFileType(i)) Then 'UCase함수를 이용해 대문자로 변환해서 비교합니다.
		  notUpChk = True
		End If
	Next

   If notUpChk Then
	  Response.write messageBack("다운로드 불가능한 파일입니다.")
	  Response.end
   End If 

	ie_version = Request.ServerVariables("HTTP_USER_AGENT")
	Response.Clear
	Response.ContentType = "application/octet_stream"
	Response.AddHeader "Content-Disposition","attachment;filename=" & Server.URLPathEncode(filename) & ""
	Response.AddHeader "Content-Transfer-Encoding", "binary"
	Response.AddHeader "Pragma", "no-cache"
	Response.AddHeader "Expires", "0"

Function isFileNotExist(filePath)
  Dim fso, result
  Set fso = CreateObject("Scripting.FileSystemObject")
  If fso.FileExists(filePath) Then
    isFileNotExist = false
  Else
    isFileNotExist = true
  End If
End Function

Function messageBack(message)
    messageBack = "<script>alert('" & message & "'); history.back();</script>"
End Function
%> 
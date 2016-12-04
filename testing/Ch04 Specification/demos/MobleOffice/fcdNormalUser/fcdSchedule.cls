VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "fcdSchedule"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"3DABFBD902F6"
Attribute VB_Ext_KEY = "RVB_ModelStereotype" ,"Class Module"
'�����ճ̰��š�

Option Explicit


'ɾ���ճ̡�
'������
'ID: long
'�ճ̰��ŵı�ʶ
'##ModelId=3DAFB65102D4
Public Sub DeleteSchedule(ID As Long)
    Dim mos As New MOScheduleLib.ScheduleManager
    
    'Set mos = CreateObject("MOScheduleLib.ScheduleManager")
    mos.Delete (ID)
    
End Sub


'�õ�һ���ռ�¼����
'������
'Return: Recordset
'����һ���ռ�¼��
'##ModelId=3DAFB79C0221
Public Function GetEmptyRecordset() As Recordset
    Dim rs As ADODB.Recordset
    Set rs = CreateObject("ADODB.Recordset")

    rs.Fields.Append "UserID", adInteger, 4
    rs.Fields.Append "Title", adVarChar, 20
    rs.Fields.Append "Schedule", adVarChar, 50

    rs.Open
    rs.AddNew
    
    Set GetEmptyRecordset = rs
End Function


'�����ճ̰�����Ϣ��
'������
'rs: recordset
'�����ճ̰�����Ϣ�ļ�¼��
'##ModelId=3DAFB7C60067
Public Sub SaveScheduleInfo(rs As Recordset)
    Dim mos As New MOScheduleLib.ScheduleManager
    mos.Add rs!UserID, rs!Title, ScheduleToDb(rs!schedule)
    
End Sub


'�õ�ָ���û����ճ̰����б���
'������
'UserID: long
'�û���ʶ
'return: recordset
'�ճ̰����б�
'##ModelId=3DAD2D5502CD
Public Function GetScheduleList(UserID As Long) As Recordset
    Dim mos As New MOScheduleLib.ScheduleManager
    Dim rs As New ADODB.Recordset
    Dim var As Variant
    Dim i As Integer, j As Integer
    
    rs.Fields.Append "ID", adInteger, 4
    rs.Fields.Append "Title", adVarChar, 20
    rs.Fields.Append "Schedule", adVarChar, 50
    
    var = mos.GetListByUserID(UserID)
    
    rs.Open
    
    For i = 0 To UBound(var, 1)
        rs.AddNew
        rs!ID = var(i, 0)
        rs!Title = var(i, 1)
        rs!schedule = ScheduleToWeb(var(i, 2))
    Next i
    
    Set GetScheduleList = rs
    
End Function



' �ı��ճ̰����ַ���Ϊ���ݿ��ʽ
' [�ճ̸�ʽ]
' 2002-10-8 13:00 �����ճ�ʱ��
' ey-em-ed 13:00  ÿ�� 13:00
' ey-em-28 13:00  ÿ��28�� 13:00
' ey-10-19 13:00  ÿ��10��19�� 13:00
' ew1/27w2 13:00  ÿ��һ 13:00 / ÿ���27�ܵ��ܶ�

' [����˵��]
' ey / em / ed / ew �ֱ��ʾ every year / every month / every day / every week
' ��ѭ��Ŀǰ������ǰ����ַ���ÿ��ָ���ܵĹ����������䡣
' ��ѭ���ĵ�����ַ���ʾ�ڼ��ܡ���Χ 1��7���ֱ��ʾ���ա���������û�г����˷�Χʱ����������ַ������ԡ�
' ����Ϊʲô��3=�ܶ���7=��������ԭ�򣺶����߼����Զ���ö�ٱ�ʾ���ڣ����ҹ��������շ�����λ��ö��Ĭ�ϵ�һ��ֵΪ 1�����Ե������������vbscript / vc �������ֱ�ʾ������javascript ���� 0��6 ��ʾ��
'
Private Function ScheduleToDb(ByVal str As String) As String
    Dim s As String
    Select Case Left(str, 2)
        Case "ÿ��"
            s = "ey-em-ed " + Right(str, 5)
        Case "ÿ��"
            s = "ew"
            Select Case Mid(str, 6, 1)
                Case "��":  s = s & "1"
                Case "һ":  s = s & "2"
                Case "��":  s = s & "3"
                Case "��":  s = s & "4"
                Case "��":  s = s & "5"
                Case "��":  s = s & "6"
                Case "��":  s = s & "7"
            End Select
            s = s & "/rese " & Right(str, 5)
        Case "ÿ��"
            s = "ey-em-" & Mid(str, 5, 2) & " " & Right(str, 5)
        Case "ÿ��"
            s = "ey-" & Mid(str, 4, 2) & "-" & Mid(str, 7, 2) & " " & Right(str, 5)
        Case Else
            ' normal alert schedule (not cycle).
            s = str
    End Select
    ScheduleToDb = s
End Function


' �ı��ճ̰����ַ���Ϊ web �����ʽ
' ��ʽ�������£�
' 2002-10-18 13:00
' ÿ��,13:00
' ÿ�ܵ�����һ,13:00
' ÿ�µĵ�02��,13:00
' ÿ���01��01��,13:00
'
Private Function ScheduleToWeb(ByVal str As String) As String
    Dim s As String
    Select Case Left(str, 2)
        Case "ey"
            If Mid(str, 7, 2) = "ed" Then
                s = "ÿ��," & Right(str, 5)
            ElseIf Mid(str, 4, 2) = "em" Then
                s = "ÿ�µĵ�" & Mid(str, 7, 2) & "��," & Right(str, 5)
            Else
                s = "ÿ���" & Mid(str, 4, 2) & "��" & Mid(str, 7, 2) & "��," & Right(str, 5)
            End If
        Case "ew"
            s = "ÿ�ܵ�����"
            Select Case Mid(str, 3, 1)
                Case 1: s = s + "��"
                Case 2: s = s + "һ"
                Case 3: s = s + "��"
                Case 4: s = s + "��"
                Case 5: s = s + "��"
                Case 6: s = s + "��"
                Case 7: s = s + "��"
            End Select
            s = s + "," + Right(str, 5)
        Case Else
            s = str
    End Select
    ScheduleToWeb = s
End Function
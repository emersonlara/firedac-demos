unit UPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UBasePrincipal, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmPrincipal = class(TFrmBasePrincipal)
    GroupBox1: TGroupBox;
    LstTabelas: TListBox;
    BtnSelecionar: TButton;
    LstCampos: TListBox;
    Splitter1: TSplitter;
    DataSource1: TDataSource;
    FDQuery1: TFDQuery;
    GroupBox2: TGroupBox;
    DBGrid1: TDBGrid;
    BtnMostrarObjetos: TButton;
    PageControl2: TPageControl;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    DBGrid2: TDBGrid;
    Splitter2: TSplitter;
    GroupBox3: TGroupBox;
    MemSQL: TMemo;
    Panel1: TPanel;
    BtnSQLExecutar: TButton;
    MemComandoExecutado: TMemo;
    procedure LstTabelasClick(Sender: TObject);
    procedure BtnMostrarObjetosClick(Sender: TObject);
    procedure BtnSelecionarClick(Sender: TObject);
    procedure BtnSQLExecutarClick(Sender: TObject);
  private
    procedure PopularListaTabelas(const ALista: TListBox);
    procedure PopularListaCampos(const ATabela: string; const ALista: TListBox);
  public

  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  UFBConnection, UConfig;

{$R *.dfm}

procedure TFrmPrincipal.PopularListaTabelas(const ALista: TListBox);
begin
  DtmFBConnection.FDConnection1.Open;
  DtmFBConnection.FDConnection1.GetTableNames('', '', '', ALista.Items);

  if ALista.Count > 0 then
    ALista.ItemIndex := 0;
end;

procedure TFrmPrincipal.PopularListaCampos(const ATabela: string; const ALista: TListBox);
begin
  DtmFBConnection.FDConnection1.Open;
  DtmFBConnection.FDConnection1.GetFieldNames('', '', ATabela, '', ALista.Items);

  if ALista.Count > 0 then
    ALista.ItemIndex := 0;
end;

procedure TFrmPrincipal.LstTabelasClick(Sender: TObject);
var
  NomeTabela: string;
begin
  NomeTabela := LstTabelas.Items[LstTabelas.ItemIndex];

  LstCampos.Clear;
  if not NomeTabela.Trim.IsEmpty then
    PopularListaCampos(NomeTabela, LstCampos);
end;

procedure TFrmPrincipal.BtnMostrarObjetosClick(Sender: TObject);
begin
  PopularListaTabelas(LstTabelas);
  LstTabelasClick(Sender);
end;

procedure TFrmPrincipal.BtnSelecionarClick(Sender: TObject);
var
  ListaCampos: string;

  function GetFieldList: string;
  var
    I: Integer;
  begin
    Result := EmptyStr;

    for I := 0 to LstCampos.Count - 1 do
    begin
      if LstCampos.Selected[I] then
      begin
        if Result.Trim.IsEmpty then
          Result := LstCampos.Items[I]
        else
          Result := Result + ',' + LstCampos.Items[I];
      end;
    end;
  end;

begin
  ListaCampos := GetFieldList;
  if ListaCampos.Trim.IsEmpty then
    raise Exception.Create('Nenhum campo foi selecionado!');

  FDQuery1.Close;
  FDQuery1.SQL.Text := 'select &campos from &tabela';
  FDQuery1.MacroByName('campos').AsRaw := ListaCampos;
  FDQuery1.MacroByName('tabela').AsRaw := LstTabelas.Items[LstTabelas.ItemIndex];
  FDQuery1.Prepare;
  FDQuery1.Open;

  MemComandoExecutado.Text := FDQuery1.Text;
end;

procedure TFrmPrincipal.BtnSQLExecutarClick(Sender: TObject);
begin
  FDQuery1.Close;
  FDQuery1.SQL.Text := MemSQL.Text;
  FDQuery1.Open;

  MemComandoExecutado.Text := FDQuery1.Text;
end;

end.

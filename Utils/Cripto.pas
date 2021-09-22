unit Cripto;

interface

uses SysUtils;

    Function Criptografa(Texto : String; Chave : smallint; PosicaoI : Smallint; Engana : Smallint) : String;
    Function DesCriptografa(Texto : String; Chave : smallint; PosicaoI : Smallint; Engana : Smallint) : String;
    function PreparaCriptografia(Texto : string; Engana : Smallint) : string;
    function PreparaDescriptografia(Texto : string; Engana : Smallint) : string;

implementation
const
      SeriaisLiberados : array[0..6] of string = ('      MPBCL0X5JPA0VG',//Notebook
                                                  'R1A118CC            ',//PC do Adelino
                                                  '0611J1FWC23841      ',//PC do Adelino com HD do Elves
                                                  '206A71D9AE3BFBFEBFBFF',//PC suporte Win7 (placa mae)
                                                  '206559AE3BDBFEBFBFF',//PC programação Win7 (placa mae)
                                                  '306A93D9AE3BFBFEBFBFF',//PC Do Alessandro Win7 64bits (placa mae)
                                                  '306F0FEFA32031F8BFBFF');//PC Servidor Portal.com do Google Cloud PlatForm Win Server 2016 (placa mae)

      Chaves : array[0..49] of string = ('XF7LW4KHA3NPEQU1TY6DZCS5BOM92G0JI8RV',
                                         '3JZL9B45HMPR0KUS1W2GINYDAOQCVX78TE6F',
                                         'MZ45KHE3UD71VWJYLC90QPTB8SFIGXAO26RN',
                                         'LE7PNKQW83YMV24X6J0CGBRZSDAUF9HI5OT1',
                                         'US8WRCV19EN4OIF23L6M5BX0YAZTHGQKJP7D',
                                         'QO147ED3NYT6SH0JLPWKGFMU9XVZ28RI5CBA',
                                         'P916IEHDV8CXLAUJY7BTRZ4W3N0F2S5QOKGM',
                                         '3KN51STFMP709I28CGZDVLXHBYQOR6JW4EAU',
                                         'AUCJB6KXV8E0P4HFGLO2YDSZRM3Q57TN9W1I',
                                         '6QXH9DCZVE7S85310TRFOIGWNPUKMYL4AJ2B',
                                         'N7I8QYH2P1J0CT6UZKD5AV9LFRB4SGMEOXW3',
                                         'IRX5V9GKNSECU2D36ZPBLYAQ7JMW84HFO01T',
                                         '1D4M0XQEBLR895GK7PYIWOT26JUVFZACHN3S',
                                         'H4XQW6OCL8F9DREIPTB5ZN0V31YGMAU27JSK',
                                         'DL8KNFJZ9IHTB634VQGPU0SWY7MEO25X1CRA',
                                         '64HZYCERG7TPB50KFXMDV9AQ8W3S1J2ONLIU',
                                         'T4P61RNIOLBWEVMHD3K9CXSZFYUJ7802G5QA',
                                         'DTSI8GZ3AWLX9YRB2Q4K6F0U7NJH5MOV1PCE',
                                         '82L65BWI3DG0MXJ7ROPAVQKENUZ4YTHFS19C',
                                         'Q5KDTS84ZRFLCH1EGJ2POYUX9MNIBW3V067A',
                                         'CLXU8AS6MT0QFH12YP9JNO3WZRVID54BEKG7',
                                         '40H873RBIAVNE6LJMXKFWUSDOCTPZ12YG9Q5',
                                         '0OXCR4SB7WFJ3PKEUIQAVLN8YGMH15D2Z9T6',
                                         'BMNX69UZS2RGEP1F87H0D4QAV3WKYCTI5OLJ',
                                         'AIBHPTJCESZWFO182XU9573YDRLQV4G6N0KM',
                                         'CHAI6MQDZ1RB47JO3XUTSY802L95EGWKVPNF',
                                         '6AYXP1LHKOTZ3CRU9BW802E4V5MISNFG7DJQ',
                                         'X4RSF3JUVEWNHKMY6GLZP0T5BQDC7891O2IA',
                                         '89H2WD56FM4NRX1ASZ7K03YEOIQGPUJLVTCB',
                                         '09WQNIMXKBO6ETZ534DURYHL7F1SJP82CAVG',
                                         'JQ2YP85KHGVDT01A4BXOUI7RSMWN63LFC9ZE',
                                         'DZAJB8OLXPGSIN71FRQ953CM0H4W2ETKV6YU',
                                         '4816KEMIHFLAOUCYSPGTN9RBJQ5ZV7XDW302',
                                         'OAS07GYXPZ5BH96K8WTJCNREV3IQ4DLF1U2M',
                                         'HQ7GOTP1M8FNVCB9AE3S6W25ZY4KDXR0JIUL',
                                         'M8AV2GZL9CTBXPSRUENW1O5D4JKFHQ036Y7I',
                                         'RQE0A7YXL6NOIU52KFCTV8PH3DZGSJ49MB1W',
                                         'F7XZI6SBK0NYUE41CVJPDQMT5HW9AG23OR8L',
                                         'XF3MTZC460SIU2BHNK891PR5GEOQVJWALYD7',
                                         'GSTOYCKVU7PFJ6QAX0Z4912LR3IEB8NMHWD5',
                                         '5D2XB7ZW4EJ3PLMNF1H6KUARSQY908TOVGIC',
                                         'S95EV0U1YFIQR7JBHGW2CZ4KDTNMA8X6O3LP',
                                         'YR0ZA64GW3EJIOL1V78F2QNHMKB5TP9SDUXC',
                                         'TUJGKZ7LF8RSY4ED6HX9W1CQMOAP5NBV320I',
                                         'AQ9CEVPBIY72ZOJUXR30LSDM6TKW51FGN48H',
                                         '6HRYG5KLOWV2QCB7MX0IZP84N9USAFTE3D1J',
                                         'DTU401NX8EHZKQ73FYPG5ORIWAJSV2BCM6L9',
                                         'TZCI092PNM3GBA7DV6LHF8OQSEXWU5RJ1K4Y',
                                         'QIXR6B4OT92WSYPLGFE17V035KZUCAJDN8HM',
                                         '2YC41IJ73WV9OU0FASXPBT8ZGDNQHK6ME5RL');

procedure ChangeByteOrder( var Data; Size : Integer );
var
ptr : PChar;
i : Integer;
c : Char;
begin
  ptr := @Data;
  for i := 0 to (Size shr 1)-1 do
  begin
    c := ptr^;
    ptr^ := (ptr+1)^;
    (ptr+1)^ := c;
    Inc(ptr,2);
  end;
end;

Function Criptografa(Texto : String; Chave : smallint; PosicaoI : Smallint; Engana : Smallint) : String;
var x, y, ContPuloExtra : smallint;
    ChaveUsada : string;
    z, TamanhoChave : integer;
    encontrado : boolean;
    const PuloExtra : array[0..20] of integer = (4,5,9,7,15,8,13,2,9,1,3,8,7,4,11,6,9,10,14,12,4);
begin
    ChaveUsada := Chaves[Chave];
    ContPuloExtra := 0;
    TamanhoChave := Length(ChaveUsada);
    for z := 1 to Length(Texto) do
    begin
      encontrado := False;
      for x := 1 to TamanhoChave do
      begin
        if Texto[z] = ChaveUsada[x] then
        begin
          encontrado := True;
          y := x + PosicaoI + PuloExtra[ContPuloExtra] + Engana;
          while y > TamanhoChave do
            y := y - TamanhoChave;
          Result := Result + ChaveUsada[y];
          Break;
        end;
      end;
      if not encontrado then
        Result := Result + Texto[z];
      ContPuloExtra := ContPuloExtra + 1;
      while ContPuloExtra > 20 do
        ContPuloExtra := ContPuloExtra - 20;
    end;
end;

Function DesCriptografa(Texto : String; Chave : smallint; PosicaoI : Smallint; Engana : Smallint) : String;
var x, y, ContPuloExtra : smallint;
    ChaveUsada : string;
    z, TamanhoChave : integer;
    encontrado : boolean;
    const PuloExtra : array[0..20] of integer = (4,5,9,7,15,8,13,2,9,1,3,8,7,4,11,6,9,10,14,12,4);
begin
    ChaveUsada := Chaves[Chave];
    ContPuloExtra := 0;
    TamanhoChave := Length(ChaveUsada);
    for z := 1 to Length(Texto) do
    begin
      encontrado := False;
      for x := 1 to TamanhoChave do
      begin
        if Texto[z] = ChaveUsada[x] then
        begin
          encontrado := True;
          y := x - PosicaoI - PuloExtra[ContPuloExtra] - Engana;
          while y < 1 do
            y := y + TamanhoChave;
          Result := Result + ChaveUsada[y];
          Break;
        end;
      end;
      if not encontrado then
        Result := Result + Texto[z];
      ContPuloExtra := ContPuloExtra + 1;
      while ContPuloExtra > 20 do
        ContPuloExtra := ContPuloExtra - 20;
    end;
end;

function PreparaCriptografia(Texto : string; Engana : Smallint):string;
var ContraSenha, PosicaoIT, ChaveT, CriptografarMix : string;
    PosicaoI, Chave : smallint;
begin
    Randomize;
    Chave := Random(49);
    ChaveT := FormatFloat('00', Chave);
    PosicaoI := Random(36)+1;
    PosicaoIT := FormatFloat('00', PosicaoI);
    CriptografarMix := Texto[10]+Texto[4]+Texto[1]+Texto[8]+
                       Texto[5]+Texto[12]+Texto[9]+Texto[2]+
                       Texto[11]+Texto[3]+Texto[7]+Texto[6];

    CriptografarMix := Cripto.Criptografa(CriptografarMix, Chave, PosicaoI, Engana);

    ContraSenha := copy(CriptografarMix,1,4)+PosicaoIT[2]+copy(CriptografarMix,5,2)+ChaveT[2]+copy(CriptografarMix,7,2)+ChaveT[1]+copy(CriptografarMix,9,3)+PosicaoIT[1]+copy(CriptografarMix,12,1);
    Result := copy(ContraSenha,1,4)+'-'+copy(ContraSenha,5,4)+'-'+copy(ContraSenha,9,4)+'-'+copy(ContraSenha,13,4);
end;

function PreparaDescriptografia(Texto : string; Engana : Smallint) : string;
var Senha, PosicaoIT, ChaveT, Criptografar : string;
    PosicaoI, Chave : smallint;
begin
    Criptografar := copy(Texto,1,4)+copy(Texto,6,4)+copy(Texto,11,4)+copy(Texto,16,4);
    ChaveT := Criptografar[11]+Criptografar[8];
    Chave := StrToInt(ChaveT);
    PosicaoIT := Criptografar[15]+Criptografar[5];
    PosicaoI := StrToInt(PosicaoIT);

    Senha := copy(Criptografar,1,4)+copy(Criptografar,6,2)+copy(Criptografar,9,2)+copy(Criptografar,12,3)+copy(Criptografar,16,1);

    Senha := DesCriptografa(Senha, Chave, PosicaoI, Engana);
    Result := Senha[3]+Senha[8]+Senha[10]+Senha[2]+Senha[5]+Senha[12]+Senha[11]+Senha[4]+Senha[7]+Senha[1]+Senha[9]+Senha[6];
end;

end.

unit UCL.TUThemeManager;

interface

uses
  Classes, SysUtils, TypInfo, Controls, Graphics,
  Generics.Collections,
  UCL.Classes, UCL.SystemSettings;

type
  IUThemeComponent = interface ['{C9D5D479-2F52-4BB9-8023-6EA00B5084F0}']
    procedure UpdateTheme;
  end;

  TUThemeManager = class(TComponent)
    private
      FAutoUpdateControls: Boolean;
      FCompList: TList<TComponent>;

      //  Events
      FOnBeforeColorLoading: TNotifyEvent;
      FOnBeforeUpdate: TNotifyEvent;
      FOnAfterUpdate: TNotifyEvent;

      //  Internal
      FTheme: TUTheme;
      FAccentColor: TColor;
      FColorOnBorder: Boolean;

      //  System
      FUseSystemTheme: Boolean;
      FUseSystemAccentColor: Boolean;

      //  Custom
      FCustomTheme: TUTheme;
      FCustomAccentColor: TColor;

    public
      constructor Create(aOwner: TComponent); override;
      destructor Destroy; override;
      procedure Loaded; override;

      //  Utils
      procedure Reload;
      procedure UpdateTheme;

      //  Components connecting
      class function IsThemeAvailable(const Comp: TComponent): Boolean;
      function ConnectedComponentCount: Integer;
      procedure Connect(const Comp: TComponent);
      procedure Disconnect(const Comp: TComponent);

    published
      property AutoUpdateControls: Boolean read FAutoUpdateControls write FAutoUpdateControls default true;

      //  System
      property UseSystemTheme: Boolean read FUseSystemTheme write FUseSystemTheme default true;
      property UseSystemAccentColor: Boolean read FUseSystemAccentColor write FUseSystemAccentColor default true;

      //  Custom
      property CustomTheme: TUTheme read FCustomTheme write FCustomTheme default utLight;
      property CustomAccentColor: TColor read FCustomAccentColor write FCustomAccentColor default $D77800;

      property Theme: TUTheme read FTheme stored false;
      property AccentColor: TColor read FAccentColor stored false;
      property ColorOnBorder: Boolean read FColorOnBorder stored false;

      //  Events
      property OnBeforeColorLoading: TNotifyEvent read FOnBeforeColorLoading write FOnBeforeColorLoading;
      property OnBeforeUpdate: TNotifyEvent read FOnBeforeUpdate write FOnBeforeUpdate;
      property OnAfterUpdate: TNotifyEvent read FOnAfterUpdate write FOnAfterUpdate;
  end;

implementation

{ TUThemeManager }

//  MAIN CLASS

constructor TUThemeManager.Create(aOwner: TComponent);
begin
  inherited;

  //  Objects
  FCompList := TList<TComponent>.Create;

  //  Default properties
  FAutoUpdateControls := True;

  FUseSystemTheme := True;
  FUseSystemAccentColor := True;

  FCustomTheme := utLight;
  FCustomAccentColor := $D77800;

  //  Default vars
  FTheme := utLight;
  FColorOnBorder := False;
  FAccentColor := $D77800;
end;

destructor TUThemeManager.Destroy;
begin
  FCompList.Free;
  inherited;
end;

procedure TUThemeManager.Loaded;
begin
  inherited;
  if Assigned(OnBeforeColorLoading) then
    FOnBeforeColorLoading(Self);
  Reload;
end;

//  UTILS

procedure TUThemeManager.Reload;
begin
  if csDesigning in ComponentState then
    Exit;

  //  Theme
  if not UseSystemTheme then
    FTheme := CustomTheme
  else begin
    if IsAppsUseDarkTheme then
      FTheme := utDark
    else
      FTheme := utLight;
  end;

  //  Accent color
  if not UseSystemAccentColor then
    FAccentColor := CustomAccentColor
  else
    FAccentColor := GetAccentColor;

  //  Color on border (read only)
  FColorOnBorder := IsColorOnBorderEnabled;

  //  Update for controls
  if AutoUpdateControls then
    UpdateTheme;
end;

procedure TUThemeManager.UpdateTheme;
var
  Comp: TComponent;
begin
  if Assigned(FOnBeforeUpdate) then
    FOnBeforeUpdate(Self);

  for Comp in FCompList do begin
    if Comp <> Nil then
      (Comp as IUThemeComponent).UpdateTheme;
  end;

  if Assigned(FOnAfterUpdate) then
    FOnAfterUpdate(Self);
end;

//  COMPONENTS CONNECTING

class function TUThemeManager.IsThemeAvailable(const Comp: TComponent): Boolean;
begin
  Result := IsPublishedProp(Comp, 'ThemeManager') and Supports(Comp, IUThemeComponent);
end;

function TUThemeManager.ConnectedComponentCount: Integer;
begin
  if FCompList = Nil then
    Result := -1
  else
    Result := FCompList.Count;
end;

procedure TUThemeManager.Connect(const Comp: TComponent);
var
  ConnectedYet: Boolean;
begin
  if IsThemeAvailable(Comp) then begin
    ConnectedYet := (FCompList.IndexOf(Comp) <> -1);
    if not ConnectedYet then
      FCompList.Add(Comp);
  end;
end;

procedure TUThemeManager.Disconnect(const Comp: TComponent);
var
  Index: Integer;
begin
  Index := FCompList.IndexOf(Comp);
  if Index <> -1 then
    FCompList.Delete(Index);
end;

end.

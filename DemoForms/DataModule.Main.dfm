object dmMain: TdmMain
  OldCreateOrder = False
  Height = 224
  Width = 303
  object AppTheme: TUThemeManager
    OnBeforeUpdate = AppThemeBeforeUpdate
    OnAfterUpdate = AppThemeAfterUpdate
    Left = 160
    Top = 100
  end
end

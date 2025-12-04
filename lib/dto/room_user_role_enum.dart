enum RoomUserRoleEnum { spectrator, gameObserver }

extension RoomUserRoleEnumX on RoomUserRoleEnum {
  /// Nazwa wyświetlana w UI (możesz łatwo zmienić lub podłączyć lokalizację).
  String get displayName {
    switch (this) {
      case RoomUserRoleEnum.spectrator:
        return 'Spectator';
      case RoomUserRoleEnum.gameObserver:
        return 'Game Observer';
    }
  }
}

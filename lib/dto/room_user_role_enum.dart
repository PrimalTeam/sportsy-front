enum RoomUserRoleEnum { admin, spectrator, gameObserver }

extension RoomUserRoleEnumX on RoomUserRoleEnum {
  /// Nazwa wyświetlana w UI (możesz łatwo zmienić lub podłączyć lokalizację).
  String get displayName {
    switch (this) {
      case RoomUserRoleEnum.admin:
        return 'Admin';
      case RoomUserRoleEnum.spectrator:
        return 'Spectator';
      case RoomUserRoleEnum.gameObserver:
        return 'Game Observer';
    }
  }

  static RoomUserRoleEnum fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return RoomUserRoleEnum.admin;
      case 'spectrator':
        return RoomUserRoleEnum.spectrator;
      case 'gameobserver':
        return RoomUserRoleEnum.gameObserver;
      default:
        return RoomUserRoleEnum.spectrator;
    }
  }
}

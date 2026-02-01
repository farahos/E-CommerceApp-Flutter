enum UserRole {
  admin,
  user;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.user:
        return 'User';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}

enum ProductSort {
  newest,
  priceLowToHigh,
  priceHighToLow,
  nameAZ,
  nameZA;

  String get displayName {
    switch (this) {
      case ProductSort.newest:
        return 'Cusub';
      case ProductSort.priceLowToHigh:
        return 'Qiimo: Kor u kac';
      case ProductSort.priceHighToLow:
        return 'Qiimo: Hoos u dhac';
      case ProductSort.nameAZ:
        return 'Magac: A-Z';
      case ProductSort.nameZA:
        return 'Magac: Z-A';
    }
  }
}

enum OrderStatus {
  pending,
  paid,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Sugaya';
      case OrderStatus.paid:
        return 'Lacag bixiyay';
      case OrderStatus.shipped:
        return 'La diray';
      case OrderStatus.delivered:
        return 'Gaarsiisay';
      case OrderStatus.cancelled:
        return 'La joojiyay';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.paid:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return OrderStatus.paid;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}

enum ViewType {
  grid,
  list;

  IconData get icon {
    switch (this) {
      case ViewType.grid:
        return Icons.grid_view;
      case ViewType.list:
        return Icons.list;
    }
  }
}

enum ButtonSize {
  small,
  medium,
  large;

  double get height {
    switch (this) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double get fontSize {
    switch (this) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }
}
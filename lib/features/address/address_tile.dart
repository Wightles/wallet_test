import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:wallet_test/core/theme/app_tokens.dart';
import 'package:wallet_test/features/address/address_display.dart';
import 'package:wallet_test/features/address/address_tile_bloc.dart';

class AddressTile extends StatefulWidget {
  const AddressTile({
    super.key,
    required this.address,
    required this.network,
  });

  final String address;
  final String network;

  @override
  State<AddressTile> createState() => _AddressTileState();
}

class _AddressTileState extends State<AddressTile> {
  static const double _maxDisplayTextScaleFactor = 1.4;

  late final AddressTileBloc _bloc = GetIt.instance<AddressTileBloc>();

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressTileBloc, AddressTileState>(
      bloc: _bloc,
      builder: (context, state) {
        final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
        final displayTextScaleFactor =
            textScaleFactor > _maxDisplayTextScaleFactor
                ? _maxDisplayTextScaleFactor
                : textScaleFactor;
        final displayTextScaler = TextScaler.linear(displayTextScaleFactor);
        final IconData icon;
        final Color iconColor;

        if (state.error != null) {
          icon = Icons.error_outline;
          iconColor = AppTokens.danger;
        } else if (state.copied) {
          icon = Icons.check;
          iconColor = AppTokens.success;
        } else {
          icon = Icons.copy;
          iconColor = AppTokens.textSecondary;
        }

        return Container(
          height: AppTokens.cellHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.horizontalPadding,
          ),
          color: AppTokens.surface,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.network,
                      textScaler: displayTextScaler,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.verticalGap),
                    Text(
                      formatAddressForCell(
                        widget.address,
                        textScaleFactor,
                      ),
                      textScaler: displayTextScaler,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTokens.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.gapTextIcon),
              SizedBox.square(
                dimension: AppTokens.tapTarget,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _bloc.add(CopyTapped(widget.address)),
                  icon: Icon(
                    icon,
                    size: AppTokens.iconSize,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

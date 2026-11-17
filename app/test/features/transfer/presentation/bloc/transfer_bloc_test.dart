import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jwallet_lite/core/failure/failure.dart';
import 'package:jwallet_lite/features/transfer/domain/entities/transfer_request_entity.dart';
import 'package:jwallet_lite/features/transfer/presentation/bloc/transfer_bloc.dart';
import 'package:jwallet_lite/features/transfer/presentation/bloc/transfer_event.dart';
import 'package:jwallet_lite/features/transfer/presentation/bloc/transfer_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockTransferRepository repository;
  late int keyCounter;

  const insufficientBalance = ApiFailure(
    'Insufficient wallet balance for this transfer.',
    statusCode: 409,
    code: 'INSUFFICIENT_BALANCE',
  );
  const timeout = NetworkFailure('The request timed out. Please try again.');

  TransferBloc buildBloc() =>
      TransferBloc(repository, generateKey: () => 'key-${++keyCounter}');

  const reviewing = TransferState(
    status: TransferStatus.reviewing,
    request: tTransferRequest,
    idempotencyKey: 'key-1',
  );

  void stubTransfer(Future<Either<Failure, dynamic>> Function() answer) {
    when(
      () => repository.transfer(
        request: any(named: 'request'),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer((_) async {
      final result = await answer();
      return result.map((value) => tTransferResult);
    });
  }

  setUp(() {
    repository = MockTransferRepository();
    keyCounter = 0;
  });

  group('TransferReviewRequested', () {
    blocTest<TransferBloc, TransferState>(
      'moves to review with a new idempotency key',
      build: buildBloc,
      act: (bloc) => bloc.add(const TransferReviewRequested(tTransferRequest)),
      expect: () => [reviewing],
    );

    blocTest<TransferBloc, TransferState>(
      'keeps the same key when the same transfer is reviewed again after a failure',
      build: buildBloc,
      seed: () => reviewing.copyWith(
        status: TransferStatus.failure,
        failure: timeout,
        idempotencyKey: 'previous-key',
      ),
      act: (bloc) => bloc.add(const TransferReviewRequested(tTransferRequest)),
      expect: () => [reviewing.copyWith(idempotencyKey: 'previous-key')],
    );

    blocTest<TransferBloc, TransferState>(
      'generates a new key for the same details after a successful transfer',
      build: buildBloc,
      seed: () => reviewing.copyWith(
        status: TransferStatus.success,
        result: tTransferResult,
        idempotencyKey: 'previous-key',
      ),
      act: (bloc) => bloc.add(const TransferReviewRequested(tTransferRequest)),
      expect: () => [reviewing],
    );

    blocTest<TransferBloc, TransferState>(
      'generates a new key when the transfer details change',
      build: buildBloc,
      seed: () => reviewing.copyWith(idempotencyKey: 'previous-key'),
      act: (bloc) => bloc.add(
        const TransferReviewRequested(
          TransferRequestEntity(
            beneficiaryName: 'Rahul Sharma',
            mobileNumber: '9876543210',
            amount: 2000,
          ),
        ),
      ),
      expect: () => [
        isA<TransferState>()
            .having((s) => s.idempotencyKey, 'key', 'key-1')
            .having((s) => s.request?.amount, 'amount', 2000),
      ],
    );
  });

  group('TransferSubmitted', () {
    blocTest<TransferBloc, TransferState>(
      'emits success with the backend result and sends the idempotency key',
      setUp: () => stubTransfer(() async => Right(tTransferResult)),
      build: buildBloc,
      seed: () => reviewing,
      act: (bloc) => bloc.add(const TransferSubmitted()),
      expect: () => [
        reviewing.copyWith(status: TransferStatus.submitting),
        reviewing.copyWith(
          status: TransferStatus.success,
          result: tTransferResult,
        ),
      ],
      verify: (_) => verify(
        () => repository.transfer(
          request: tTransferRequest,
          idempotencyKey: 'key-1',
        ),
      ).called(1),
    );

    blocTest<TransferBloc, TransferState>(
      'emits failure for insufficient balance without allowing retry',
      setUp: () => stubTransfer(() async => const Left(insufficientBalance)),
      build: buildBloc,
      seed: () => reviewing,
      act: (bloc) => bloc.add(const TransferSubmitted()),
      expect: () => [
        reviewing.copyWith(status: TransferStatus.submitting),
        reviewing.copyWith(
          status: TransferStatus.failure,
          failure: insufficientBalance,
        ),
      ],
      verify: (bloc) => expect(bloc.state.canRetry, isFalse),
    );

    blocTest<TransferBloc, TransferState>(
      'ignores duplicate submits while a transfer is in progress',
      setUp: () => stubTransfer(() async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return Right(tTransferResult);
      }),
      build: buildBloc,
      seed: () => reviewing,
      act: (bloc) => bloc
        ..add(const TransferSubmitted())
        ..add(const TransferSubmitted())
        ..add(const TransferSubmitted()),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        reviewing.copyWith(status: TransferStatus.submitting),
        reviewing.copyWith(
          status: TransferStatus.success,
          result: tTransferResult,
        ),
      ],
      verify: (_) => verify(
        () => repository.transfer(
          request: any(named: 'request'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).called(1),
    );

    blocTest<TransferBloc, TransferState>(
      'does not submit again after a successful transfer',
      build: buildBloc,
      seed: () => reviewing.copyWith(
        status: TransferStatus.success,
        result: tTransferResult,
      ),
      act: (bloc) => bloc.add(const TransferSubmitted()),
      expect: () => <TransferState>[],
      verify: (_) => verifyNever(
        () => repository.transfer(
          request: any(named: 'request'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ),
    );

    blocTest<TransferBloc, TransferState>(
      'retries a network failure with the same idempotency key',
      setUp: () => stubTransfer(() async => Right(tTransferResult)),
      build: buildBloc,
      seed: () =>
          reviewing.copyWith(status: TransferStatus.failure, failure: timeout),
      act: (bloc) => bloc.add(const TransferSubmitted()),
      expect: () => [
        reviewing.copyWith(status: TransferStatus.submitting),
        reviewing.copyWith(
          status: TransferStatus.success,
          result: tTransferResult,
        ),
      ],
      verify: (_) => verify(
        () => repository.transfer(
          request: tTransferRequest,
          idempotencyKey: 'key-1',
        ),
      ).called(1),
    );
  });

  blocTest<TransferBloc, TransferState>(
    'TransferReset returns to the initial state',
    build: buildBloc,
    seed: () => reviewing,
    act: (bloc) => bloc.add(const TransferReset()),
    expect: () => [const TransferState()],
  );
}

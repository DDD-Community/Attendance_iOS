//
//  ProfileRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh on 7/23/25.
//

import Combine
// 프로젝트 모듈
import DomainInterface
import Model
import Service
import Entity
import ComposableArchitecture
// 외부 의존성
import Moya

final public class ProfileRepositoryImpl: ProfileInterface, @unchecked Sendable {
    @Shared(.appStorage("staffRole")) var staffRole: Staff?

    private let provider: MoyaProvider<ProfileService>

    public init(
        provider: MoyaProvider<ProfileService>? = nil
    ) {
        // 🚀 MoyaProviderPool 사용으로 메모리 최적화
        self.provider = provider ?? MoyaProviderPool.shared.authorizedProvider(for: ProfileService.self)

    }

    // MARK: - 프로필 조회
    public func getProfile() async throws -> Entity.ProfileEntity {
        // 1. 저장된 역할 정보 확인
        // staffRole이 명확하게 있으면 해당 엔드포인트 호출
        if let role = self.staffRole {
            switch role {
            case .manager:
                let dto: ProfileDTO = try await provider.request(.getAdminProfile)
                return dto.toDomain()
            case .member:
                let dto: ProfileDTO = try await provider.request(.getUserProfile)
                return dto.toDomain()
            }
        } else {
            // 2. 역할 정보가 없으면, 유저 프로필을 먼저 시도 (가장 일반적인 케이스)
            // 실패 시 어드민 프로필 시도.
            // 이 로직은 로그인 직후 역할 정보가 아직 없을 때를 위한 폴백(fallback)입니다.
            do {
                let dto: ProfileDTO = try await provider.request(.getUserProfile)
                // 성공 시 역할을 .member로 유추하여 저장
//                self.staffRole = .member
                return dto.toDomain()
            } catch {
                // getUserProfile이 실패하면 getAdminProfile 시도
                // MoyaError 중 statusCode가 401, 403, 404 등일 때만 다음을 시도하는 것이 더 안전하지만,
                // 현재 로직을 최대한 유지하는 선에서 수정합니다.
                do {
                    let dto: ProfileDTO = try await provider.request(.getAdminProfile)
                    // 성공 시 역할을 .manager로 유추하여 저장
//                    self.staffRole = .manager
                    return dto.toDomain()
                } catch {
                    // 두 가지 모두 실패하면 최종 에러를 던집니다.
                    throw error
                }
            }
        }
    }

    // MARK: - 프로필 수정
    public func editProfile(
        input: EditProfileInput
    ) async throws -> Entity.ProfileEntity {
        let body = input.toRequestDTO()
        let dto: ProfileDTO = try await provider.request(.editProfile(body: body))
        return dto.toDomain()
    }
}

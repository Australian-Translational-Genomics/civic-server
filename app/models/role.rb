class Role
  def self.user_is_at_least_a?(user, role)
    roles = user.class.roles
    roles[user.role] >= roles[role]
  end

  def self.highest_role_for_users(*users)
    roles = users.first.class.roles
    users.inject(roles.keys.first) do |max_role, user|
      if roles[user.role] > roles[max_role]
        user.role
      else
        max_role
      end
    end
  end
end

import type { InquiryRow, UserRow, OrderRow, StatsRow } from '@vibers/admin-kit';
import FanEasyDashboard from './FanEasyDashboard';

const FANEASY_URL = process.env.FANEASY_ADMIN_URL ?? 'http://localhost:3600';
const SECRET = process.env.VIBERS_ADMIN_SECRET ?? '';

async function fetchEntity<T>(entity: string): Promise<T[]> {
  try {
    const res = await fetch(`${FANEASY_URL}/api/vibers-admin/${entity}`, {
      headers: { 'x-vibers-secret': SECRET },
      next: { revalidate: 60 },
    });
    if (!res.ok) return [];
    return res.json();
  } catch {
    return [];
  }
}

export default async function FanEasyAdminPage() {
  const [stats, inquiries, users, orders] = await Promise.all([
    fetchEntity<StatsRow>('stats'),
    fetchEntity<InquiryRow>('inquiries'),
    fetchEntity<UserRow>('users'),
    fetchEntity<OrderRow>('orders'),
  ]);

  return (
    <FanEasyDashboard
      stats={stats}
      inquiries={inquiries}
      users={users}
      orders={orders}
    />
  );
}

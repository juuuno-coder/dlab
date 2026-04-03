'use client';

import React, { useState } from 'react';
import type { InquiryRow, UserRow, OrderRow, StatsRow } from '@vibers/admin-kit';
import { BarChart2, MessageSquare, Users, ShoppingCart } from 'lucide-react';

type Tab = 'stats' | 'inquiries' | 'users' | 'orders';

interface Props {
  stats: StatsRow[];
  inquiries: InquiryRow[];
  users: UserRow[];
  orders: OrderRow[];
}

const SITE_LABELS: Record<string, string> = {
  oluolu: '올루올루',
  bizon: '비존',
  cpr: 'CPR',
  yahwa: '야화',
  designd: '디자인드',
};

const WORKFLOW_LABEL: Record<string, { label: string; className: string }> = {
  received:    { label: '접수', className: 'bg-blue-100 text-blue-700' },
  in_progress: { label: '진행중', className: 'bg-yellow-100 text-yellow-700' },
  completed:   { label: '완료', className: 'bg-green-100 text-green-700' },
  cancelled:   { label: '취소', className: 'bg-neutral-200 text-neutral-500' },
};

const STATUS_LABEL: Record<string, { label: string; className: string }> = {
  paid:      { label: '결제완료', className: 'bg-green-100 text-green-700' },
  pending:   { label: '대기', className: 'bg-yellow-100 text-yellow-700' },
  cancelled: { label: '취소', className: 'bg-red-100 text-red-700' },
  refunded:  { label: '환불', className: 'bg-neutral-200 text-neutral-500' },
};

function fmt(iso: string) {
  if (!iso) return '-';
  return new Date(iso).toLocaleDateString('ko-KR', { year: '2-digit', month: '2-digit', day: '2-digit' });
}

function Badge({ map, value }: { map: Record<string, { label: string; className: string }>; value: string }) {
  const entry = map[value] ?? { label: value, className: 'bg-neutral-100 text-neutral-600' };
  return <span className={`px-2 py-0.5 rounded-full text-[11px] font-bold ${entry.className}`}>{entry.label}</span>;
}

const TABS: { id: Tab; label: string; icon: React.ReactNode }[] = [
  { id: 'stats',     label: '통계',   icon: <BarChart2 className="w-4 h-4" /> },
  { id: 'inquiries', label: '문의',   icon: <MessageSquare className="w-4 h-4" /> },
  { id: 'users',     label: '사용자', icon: <Users className="w-4 h-4" /> },
  { id: 'orders',    label: '주문',   icon: <ShoppingCart className="w-4 h-4" /> },
];

export default function FanEasyDashboard({ stats, inquiries, users, orders }: Props) {
  const [tab, setTab] = useState<Tab>('stats');

  return (
    <div className="space-y-6">
      {/* 헤더 */}
      <div className="flex justify-between items-center bg-[var(--admin-card)] p-5 rounded-xl border border-[var(--admin-border)] shadow-sm">
        <div>
          <h1 className="text-xl font-bold text-[var(--admin-text)]">FanEasy 어드민</h1>
          <p className="text-sm text-[var(--admin-text-muted)] mt-0.5">faneasy.kr — Firestore 실시간 데이터</p>
        </div>
        <span className="px-3 py-1 bg-emerald-50 text-emerald-700 text-xs font-bold rounded-full border border-emerald-100">
          LIVE
        </span>
      </div>

      {/* 탭 */}
      <div className="flex gap-1 bg-[var(--admin-card)] p-1 rounded-xl border border-[var(--admin-border)] w-fit">
        {TABS.map(t => (
          <button
            key={t.id}
            onClick={() => setTab(t.id)}
            className={`flex items-center gap-1.5 px-4 py-2 rounded-lg text-sm font-semibold transition-colors ${
              tab === t.id
                ? 'bg-slate-900 text-white shadow-sm'
                : 'text-[var(--admin-text-muted)] hover:bg-slate-50'
            }`}
          >
            {t.icon}
            {t.label}
          </button>
        ))}
      </div>

      {/* 통계 탭 */}
      {tab === 'stats' && (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {stats.length === 0 ? (
            <div className="col-span-3 bg-[var(--admin-card)] rounded-xl border border-[var(--admin-border)] p-10 text-center text-[var(--admin-text-muted)] text-sm">
              데이터 없음
            </div>
          ) : (
            stats.map(s => (
              <div key={s.siteId} className="bg-[var(--admin-card)] rounded-xl border border-[var(--admin-border)] p-5 shadow-sm">
                <div className="flex items-center justify-between mb-4">
                  <span className="text-sm font-bold text-[var(--admin-text)]">
                    {SITE_LABELS[s.siteId] ?? s.siteId}
                  </span>
                  <span className="text-[11px] text-[var(--admin-text-muted)] font-mono">{s.siteId}</span>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <p className="text-[10px] text-[var(--admin-text-muted)] uppercase font-bold tracking-wider mb-1">오늘 방문</p>
                    <p className="text-2xl font-bold text-[var(--admin-text)]">{s.todayVisits.toLocaleString()}</p>
                  </div>
                  <div>
                    <p className="text-[10px] text-[var(--admin-text-muted)] uppercase font-bold tracking-wider mb-1">이번달</p>
                    <p className="text-2xl font-bold text-[var(--admin-text)]">{s.monthVisits.toLocaleString()}</p>
                  </div>
                  <div>
                    <p className="text-[10px] text-[var(--admin-text-muted)] uppercase font-bold tracking-wider mb-1">누적 방문</p>
                    <p className="text-lg font-semibold text-[var(--admin-text)]">{s.totalVisits.toLocaleString()}</p>
                  </div>
                  <div>
                    <p className="text-[10px] text-[var(--admin-text-muted)] uppercase font-bold tracking-wider mb-1">누적 문의</p>
                    <p className="text-lg font-semibold text-[var(--admin-text)]">{s.totalInquiries.toLocaleString()}</p>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      )}

      {/* 문의 탭 */}
      {tab === 'inquiries' && (
        <div className="bg-[var(--admin-card)] rounded-xl border border-[var(--admin-border)] overflow-hidden shadow-sm">
          <div className="p-4 border-b border-[var(--admin-border)] flex items-center justify-between">
            <span className="font-bold text-sm text-[var(--admin-text)]">문의 목록</span>
            <span className="text-xs text-[var(--admin-text-muted)]">총 {inquiries.length}건</span>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-[var(--admin-border)] bg-slate-50/50">
                  {['이름', '연락처', '이메일', '사이트', '플랜', '상태', '날짜'].map(h => (
                    <th key={h} className="text-left px-4 py-3 text-[11px] font-bold text-[var(--admin-text-muted)] uppercase tracking-wider whitespace-nowrap">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {inquiries.length === 0 ? (
                  <tr><td colSpan={7} className="text-center py-10 text-[var(--admin-text-muted)]">데이터 없음</td></tr>
                ) : inquiries.map(row => (
                  <tr key={row.id} className="border-b border-[var(--admin-border)] hover:bg-slate-50/30 transition-colors">
                    <td className="px-4 py-3 font-medium text-[var(--admin-text)] whitespace-nowrap">{row.name}</td>
                    <td className="px-4 py-3 text-[var(--admin-text-muted)] whitespace-nowrap">{row.phone}</td>
                    <td className="px-4 py-3 text-[var(--admin-text-muted)]">{row.email}</td>
                    <td className="px-4 py-3 whitespace-nowrap">
                      <span className="px-2 py-0.5 bg-indigo-50 text-indigo-700 rounded text-[11px] font-bold">
                        {SITE_LABELS[row.siteId] ?? row.siteId}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-[var(--admin-text-muted)]">{row.plan}</td>
                    <td className="px-4 py-3 whitespace-nowrap">
                      <Badge map={WORKFLOW_LABEL} value={row.workflowStatus} />
                    </td>
                    <td className="px-4 py-3 text-[var(--admin-text-muted)] whitespace-nowrap">{fmt(row.createdAt)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* 사용자 탭 */}
      {tab === 'users' && (
        <div className="bg-[var(--admin-card)] rounded-xl border border-[var(--admin-border)] overflow-hidden shadow-sm">
          <div className="p-4 border-b border-[var(--admin-border)] flex items-center justify-between">
            <span className="font-bold text-sm text-[var(--admin-text)]">사용자 목록</span>
            <span className="text-xs text-[var(--admin-text-muted)]">총 {users.length}명</span>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-[var(--admin-border)] bg-slate-50/50">
                  {['이메일', '이름', '역할', '가입일'].map(h => (
                    <th key={h} className="text-left px-4 py-3 text-[11px] font-bold text-[var(--admin-text-muted)] uppercase tracking-wider whitespace-nowrap">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {users.length === 0 ? (
                  <tr><td colSpan={4} className="text-center py-10 text-[var(--admin-text-muted)]">데이터 없음</td></tr>
                ) : users.map(row => (
                  <tr key={row.id} className="border-b border-[var(--admin-border)] hover:bg-slate-50/30 transition-colors">
                    <td className="px-4 py-3 text-[var(--admin-text)]">{row.email}</td>
                    <td className="px-4 py-3 font-medium text-[var(--admin-text)]">{row.name}</td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-0.5 rounded text-[11px] font-bold ${row.role === 'admin' ? 'bg-purple-100 text-purple-700' : 'bg-neutral-100 text-neutral-600'}`}>
                        {row.role}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-[var(--admin-text-muted)] whitespace-nowrap">{fmt(row.createdAt)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* 주문 탭 */}
      {tab === 'orders' && (
        <div className="bg-[var(--admin-card)] rounded-xl border border-[var(--admin-border)] overflow-hidden shadow-sm">
          <div className="p-4 border-b border-[var(--admin-border)] flex items-center justify-between">
            <span className="font-bold text-sm text-[var(--admin-text)]">주문 목록</span>
            <span className="text-xs text-[var(--admin-text-muted)]">총 {orders.length}건</span>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-[var(--admin-border)] bg-slate-50/50">
                  {['구매자', '이메일', '상품ID', '금액', '상태', '날짜'].map(h => (
                    <th key={h} className="text-left px-4 py-3 text-[11px] font-bold text-[var(--admin-text-muted)] uppercase tracking-wider whitespace-nowrap">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {orders.length === 0 ? (
                  <tr><td colSpan={6} className="text-center py-10 text-[var(--admin-text-muted)]">데이터 없음</td></tr>
                ) : orders.map(row => (
                  <tr key={row.id} className="border-b border-[var(--admin-border)] hover:bg-slate-50/30 transition-colors">
                    <td className="px-4 py-3 font-medium text-[var(--admin-text)] whitespace-nowrap">{row.buyerName}</td>
                    <td className="px-4 py-3 text-[var(--admin-text-muted)]">{row.buyerEmail}</td>
                    <td className="px-4 py-3 font-mono text-xs text-[var(--admin-text-muted)]">{row.productId}</td>
                    <td className="px-4 py-3 font-semibold text-[var(--admin-text)] whitespace-nowrap">
                      {row.amount.toLocaleString('ko-KR')}원
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap">
                      <Badge map={STATUS_LABEL} value={row.status} />
                    </td>
                    <td className="px-4 py-3 text-[var(--admin-text-muted)] whitespace-nowrap">{fmt(row.createdAt)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}

import React from 'react';
import Card from '@/components/ui/Card';
import { Zap, TextQuote, AlertCircle } from 'lucide-react';
import type { InsightCard } from '@/types';

interface InsightsPanelProps {
  insights: InsightCard[];
}

const InsightsPanel: React.FC<InsightsPanelProps> = ({ insights }) => {
  const headlineInsights = insights.slice(0, 2);
  const topPairs = insights.slice(2);

  return (
    <Card title="Qualitative Pair Insights Highlights" icon={Zap}>
      {insights.length === 0 ? (
        <div className="text-sm text-gray-500">
          No insights yet. Upload a workbook to generate qualitative highlights.
        </div>
      ) : (
        <div className="space-y-6">
          {headlineInsights.map((insight, index) => {
            const isHigh = insight.title.includes('Most Common');
            const Icon = isHigh ? TextQuote : AlertCircle;
            const color = isHigh ? 'text-[#00b894]' : 'text-[#ff7675]';
            const bgColor = isHigh ? 'bg-[#55efc4]/10' : 'bg-[#ff7675]/10';
            const gradientAccent = isHigh
              ? 'from-[#55efc4]/20 to-[#81ecec]/10'
              : 'from-[#ff7675]/20 to-[#ff9f43]/10';

            return (
              <div
                key={index}
                className="relative overflow-hidden rounded-2xl border border-[color:var(--border-soft)] bg-white p-5"
              >
                <div className={`absolute inset-0 bg-gradient-to-br ${gradientAccent} opacity-50`} />
                <div className="relative z-[1]">
                  <div className="mb-3 flex items-center gap-3">
                    <div className={`rounded-lg p-2 ${bgColor}`}>
                      <Icon className={`h-5 w-5 ${color}`} />
                    </div>
                    <h4 className="font-semibold text-gray-950">{insight.title}</h4>
                    {insight.subtitle && (
                      <span className="ml-auto text-xs font-medium text-gray-500">
                        Score: {insight.subtitle}
                      </span>
                    )}
                  </div>
                  <p className="text-sm leading-relaxed text-gray-700">"{insight.text}"</p>
                </div>
              </div>
            );
          })}

          {topPairs.length > 0 && (
            <>
              <div className="flex items-center gap-3 text-xs font-medium uppercase tracking-[0.08em] text-gray-500">
                <div className="h-px flex-1 bg-[color:var(--border-soft)]" />
                Top Pairs (#2–#5)
                <div className="h-px flex-1 bg-[color:var(--border-soft)]" />
              </div>
              {topPairs.map((insight, index) => {
                const Icon = AlertCircle;
                const color = 'text-[#ff7675]';
                const bgColor = 'bg-[#ff7675]/10';
                const gradientAccent = 'from-[#ff7675]/12 to-[#ff9f43]/8';

                return (
                  <div
                    key={`top-${index}`}
                    className="relative overflow-hidden rounded-2xl border border-[color:var(--border-soft)] bg-white p-5"
                  >
                    <div className={`absolute inset-0 bg-gradient-to-br ${gradientAccent}`} />
                    <div className="relative z-[1]">
                      <div className="mb-3 flex items-center gap-3">
                        <div className={`rounded-lg p-2 ${bgColor}`}>
                          <Icon className={`h-5 w-5 ${color}`} />
                        </div>
                        <h4 className="font-semibold text-gray-950">{insight.title}</h4>
                        {insight.subtitle && (
                          <span className="ml-auto text-xs font-medium text-gray-500">
                            Score: {insight.subtitle}
                          </span>
                        )}
                      </div>
                      <p className="text-sm leading-relaxed text-gray-700">"{insight.text}"</p>
                    </div>
                  </div>
                );
              })}
            </>
          )}
        </div>
      )}
    </Card>
  );
};

export default InsightsPanel;

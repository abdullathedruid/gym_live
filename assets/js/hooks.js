let Hooks={}
Hooks.Chart = {
    mounted() {
        const chartConfig = JSON.parse(this.el.dataset.config)
        const seriesData = JSON.parse(this.el.dataset.series)
        const categoriesData = JSON.parse(this.el.dataset.categories)

        const options = {
            chart: Object.assign({background: 'transparent'}, chartConfig),
            series: seriesData,
            xaxis: {
                categories: categoriesData,
                type: 'datetime',
                labels: {
                    datetimeFormatter: {
                        year: 'yyyy',
                        month: 'MMM \'yy',
                        day: 'dd MMM',
                        hour: 'HH:mm'
                    }
                }
            },
            markers: {
                size: [6, 0]
            },
            tooltip: {
                shared: false,
                intersect: true
            }
        }

        let chart = new ApexCharts(this.el, options)
        chart.render()
    }
}

export default Hooks;
